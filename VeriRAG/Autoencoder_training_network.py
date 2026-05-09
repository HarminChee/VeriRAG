# ===============================================
# This script implements the VeriRAG framework
# for DFT-aware RTL design repair using a retrieval-augmented approach.
# It consists of the following major components:
# - Preprocessing and clustering DFT error patterns from logs
# - Converting Verilog JSON to TF-IDF vectors
# - Training a multi-task autoencoder with contrastive learning
# - Generating embeddings and similarity matrices
# - Retrieving most similar reference design for each test design
# - Visualizing similarity heatmaps in batches
# - Exporting highest similarity test-reference design pairs (above threshold)
# All annotations are added to help new users understand and utilize the pipeline.
# - All Copyright at VeriRAG Qi, etc.
# ===============================================

import os
import json
import numpy as np
import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from sklearn.cluster import KMeans
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
import seaborn as sns
import matplotlib.pyplot as plt
import torch.nn.functional as F   # for z normalization


# =====================================
# Step 0: Read Excel & Build cluster_map
# =====================================
def cluster_warning_logs(excel_path, out_path=None):
    """
    Read 4 columns from Excel ('ACNCPI', 'CLKNPI', 'FFCKNP', 'CDFDAT'),
    cluster them into 4 clusters using KMeans,
    and generate a cluster_map: {json_name -> 0..3}.
    """
    df = pd.read_excel(excel_path)
    bit_cols = ["ACNCPI", "CLKNPI", "FFCKNP", "CDFDAT"]
    for c in bit_cols:
        if c not in df.columns:
            df[c] = 0
    X = df[bit_cols].fillna(0).values

    kmeans = KMeans(n_clusters=4, random_state=42)
    kmeans.fit(X)
    df["cluster"] = kmeans.labels_

    def make_json_name(fn):
        # e.g. module_1745.v -> 1745.json
        return fn.replace("module_", "").replace(".v", "") + ".json"

    df["json_name"] = df["file"].apply(make_json_name)

    if out_path:
        df.to_excel(out_path, index=False)
        print(f"[Info] Clustered DataFrame saved to: {out_path}")

    cluster_map = dict(zip(df["json_name"], df["cluster"]))
    return df, cluster_map


# =====================================
# Step 2: TF-IDF Dataset
# =====================================
class TFIDFDataset(Dataset):
    """
    Flatten JSON files into text, vectorize using TfidfVectorizer.
    Cluster IDs are loaded for each sample.
    Files whose cluster_map[basename] is not in [0..3] are skipped.
    """
    def __init__(self, json_files, cluster_map, max_features=512):
        self.json_files = json_files
        self.cluster_map = cluster_map or {}
        self.max_features = max_features
        self.data, self.labels, self.vec_size = self._prepare_data()

    def _flatten_json(self, obj):
        """
        Recursively flatten JSON object into a single text string, for TF-IDF processing.
        """
        lines = []
        if isinstance(obj, dict):
            for k, v in obj.items():
                lines.append(f"{k}:{self._flatten_json(v)}")
            return ", ".join(lines)
        elif isinstance(obj, list):
            for i, x in enumerate(obj):
                lines.append(f"item_{i}:{self._flatten_json(x)}")
            return ", ".join(lines)
        else:
            return str(obj)

    def _prepare_data(self):
        texts = []
        filenames = []
        for jf in self.json_files:
            with open(jf, "r", encoding="utf-8") as f:
                c = json.load(f)
            text = self._flatten_json(c)
            texts.append(text)
            filenames.append(os.path.basename(jf))

        vectorizer = TfidfVectorizer(max_features=self.max_features)
        X_all = vectorizer.fit_transform(texts).toarray()  # shape: (N, max_features)

        data_list = []
        label_list = []
        for i, fn in enumerate(filenames):
            cid = self.cluster_map.get(fn, -1)
            if cid < 0 or cid > 3:
                continue
            data_list.append(X_all[i])
            label_list.append(cid)

        X = np.array(data_list, dtype=np.float32)
        labels = np.array(label_list, dtype=np.int64)
        return X, labels, X.shape[1]

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        x = self.data[idx]
        label = self.labels[idx]
        return x, label


# =====================================
# Step 3: Multi-task AE + Contrastive
# =====================================
class MultiTaskAE(nn.Module):
    """
    Encoder: input_dim->512->256->latent
    Decoder: latent->256->512->input_dim
    Classifier: latent->4 (predict cluster)
    """
    def __init__(self, input_dim, latent_dim):
        super().__init__()
        # Encoder
        self.encoder = nn.Sequential(
            nn.Linear(input_dim, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(256, latent_dim)
        )
        # Decoder
        self.decoder = nn.Sequential(
            nn.Linear(latent_dim, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(),
            nn.Linear(256, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(),
            nn.Linear(512, input_dim)
        )
        # Classifier
        self.cluster_classifier = nn.Linear(latent_dim, 4)

    def forward(self, x):
        z = self.encoder(x)              # latent
        recon = self.decoder(z)          # reconstruction uses raw z
        cluster_logits = self.cluster_classifier(z)  # classification uses raw z
        return recon, z, cluster_logits


# -------------------------------------
# Contrastive loss: z normalization as needed by caller
# -------------------------------------
def contrastive_loss(z, labels, margin=1.0):
    """
    Pairwise contrastive loss: for same label, minimize distance; for different label, enforce distance > margin.
    z: (B, latent_dim)
    labels: (B,)
    """
    device = z.device
    batch_size = z.size(0)
    if batch_size < 2:
        return torch.tensor(0.0, device=device)

    total_loss = 0.0
    pair_count = 0
    for i in range(batch_size):
        for j in range(i+1, batch_size):
            dist = (z[i] - z[j]).pow(2).sum().sqrt()
            if labels[i] == labels[j]:
                total_loss += dist**2
            else:
                margin_term = torch.clamp(margin - dist, min=0)
                total_loss += margin_term**2
            pair_count += 1

    if pair_count == 0:
        return torch.tensor(0.0, device=device)
    return total_loss / pair_count


def compute_batch_margin(z_norm, labels, prev_margin, eps=1e-12):
    """
    Compute average Euclidean distance of inter-class sample pairs as dynamic margin.
    If there are no inter-class pairs, return prev_margin.
    """
    with torch.no_grad():
        B = z_norm.size(0)
        dist = torch.cdist(z_norm, z_norm, p=2)  # (B,B)
        same = labels.unsqueeze(0) == labels.unsqueeze(1)
        diff = ~same
        eye = torch.eye(B, dtype=torch.bool, device=dist.device)
        diff = diff & ~eye
        diff_dists = dist[diff]
        if diff_dists.numel() == 0:
            return prev_margin
        return diff_dists.mean().clamp(min=eps).item()


# =====================================
# Step 3b: Training (dynamic margin version)
# =====================================
def train_multitask_ae(model, dataloader, epochs=50, lr=0.001,
                       alpha=0.01, beta=0.01,
                       margin_init=1.0, ema_decay=0.9, verbose_every=1):
    """
    Training routine for multi-task autoencoder with dynamic margin for contrastive loss.
    total_loss = recon_loss + alpha * cluster_cls_loss + beta * contrastive_loss
    margin_init : initial margin (used for first batch & fallback)
    ema_decay   : EMA smoothing coefficient (0.9 = current batch 10%)
    """
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)

    recon_crit = nn.MSELoss()
    cls_crit = nn.CrossEntropyLoss()
    opt = optim.Adam(model.parameters(), lr=lr)

    cur_margin = margin_init

    for epoch in range(epochs):
        model.train()
        total_loss = 0.0
        total_recon = 0.0
        total_cls = 0.0
        total_contrast = 0.0
        total_margin = 0.0
        num_batches = 0

        for batch_x, batch_c in dataloader:
            batch_x = batch_x.to(device)
            batch_c = batch_c.to(device)

            recon, z, logits_c = model(batch_x)
            loss_recon = recon_crit(recon, batch_x)
            loss_cls = cls_crit(logits_c, batch_c)
            z_norm = F.normalize(z, p=2, dim=1, eps=1e-12)
            batch_margin = compute_batch_margin(z_norm, batch_c, prev_margin=cur_margin)
            if (ema_decay is not None) and (ema_decay < 1.0):
                cur_margin = ema_decay * cur_margin + (1.0 - ema_decay) * batch_margin
            else:
                cur_margin = batch_margin
            loss_contrast = contrastive_loss(z_norm, batch_c, margin=cur_margin)
            loss = loss_recon + alpha * loss_cls + beta * loss_contrast

            opt.zero_grad()
            loss.backward()
            opt.step()

            total_loss += loss.item()
            total_recon += loss_recon.item()
            total_cls += loss_cls.item()
            total_contrast += loss_contrast.item()
            total_margin += cur_margin
            num_batches += 1

        if num_batches > 0 and ((epoch + 1) % verbose_every == 0):
            print(f"Epoch[{epoch+1}/{epochs}] "
                  f"Loss={total_loss/num_batches:.4f}, "
                  f"Recon={total_recon/num_batches:.4f}, "
                  f"Cls={total_cls/num_batches:.4f}, "
                  f"Contrast={total_contrast/num_batches:.4f}, "
                  f"m={total_margin/num_batches:.4f}")
        elif num_batches == 0:
            print(f"Epoch[{epoch+1}/{epochs}] No valid data in DataLoader!")
            break


# =====================================
# Step 4: Generate embeddings & Similarity
# =====================================
def generate_embeddings(model, dataloader, normalize=False):
    """
    Generate latent embeddings for the whole set.
    normalize=True: apply L2 normalization to output (for cosine similarity).
    """
    model.eval()
    device = next(model.parameters()).device
    all_z = []
    with torch.no_grad():
        for batch_x, _ in dataloader:
            batch_x = batch_x.to(device)
            _, z, _ = model(batch_x)
            if normalize:
                z = F.normalize(z, p=2, dim=1, eps=1e-12)
            all_z.append(z.cpu())
    if len(all_z) == 0:
        return torch.empty(0, model.encoder[-1].out_features)
    return torch.cat(all_z, dim=0)


def calculate_similarity(emb1, emb2):
    if emb1.size(0) == 0 or emb2.size(0) == 0:
        return np.array([])  # Empty matrix
    e1 = emb1.numpy()
    e2 = emb2.numpy()
    return cosine_similarity(e1, e2)


# =====================================
# Step 5: Visualization
# =====================================
def visualize_similarity_matrix_batch(sim_matrix, row_files, col_files, cluster_map=None, batch_size=85):
    """
    Display similarity heatmap in batches, each with up to batch_size rows (test samples).
    """
    n_rows = sim_matrix.shape[0]
    n_cols = sim_matrix.shape[1]
    for start in range(0, n_rows, batch_size):
        end = min(start + batch_size, n_rows)
        batch_mat = sim_matrix[start:end, :]
        batch_row_files = row_files[start:end]

        def label_with_cluster(path_):
            bn = os.path.basename(path_)
            c = cluster_map.get(bn,"N/A") if cluster_map else "N/A"
            return f"{bn.replace('.json', '')}(C{c})"

        row_labels = [label_with_cluster(f) for f in batch_row_files]
        col_labels = [label_with_cluster(f) for f in col_files]

        plt.figure(figsize=(max(12, n_cols // 6), max(7, len(row_labels)//8)))
        sns.heatmap(batch_mat, cmap="coolwarm",
                    xticklabels=col_labels, yticklabels=row_labels)
        plt.title(f"Similarity Matrix (Test {start}-{end-1})")
        plt.show()


# =====================================
# Find file pairs with extreme similarities (>=0.95 or <=0.35)
# =====================================
def find_extreme_similarities(sim_matrix, json_files,
                              high_thr=0.95, low_thr=0.35):
    """
    Find file pairs in the similarity matrix with similarity >= high_thr or <= low_thr (exclude diagonal).
    Returns (high_pairs, low_pairs), e.g., ["11337&12378", ...].
    """
    n = len(json_files)
    high_pairs = []
    low_pairs = []
    for i in range(n):
        for j in range(n):
            if i >= j:
                continue
            sim = sim_matrix[i, j]
            if sim >= high_thr:
                base_i = os.path.basename(json_files[i]).replace(".json","")
                base_j = os.path.basename(json_files[j]).replace(".json","")
                pair_str = f"{base_i}&{base_j}"
                high_pairs.append(pair_str)
            elif sim <= low_thr:
                base_i = os.path.basename(json_files[i]).replace(".json","")
                base_j = os.path.basename(json_files[j]).replace(".json","")
                pair_str = f"{base_i}&{base_j}"
                low_pairs.append(pair_str)

    return high_pairs, low_pairs


# =====================================
# Step 6: Main pipeline
# =====================================
if __name__ == "__main__":

    # ========== All paths anonymized for open-source release ==========
    excel_path = "your_data_folder/warning_logs.xlsx"
    out_excel = "your_data_folder/warning_logs_clustered.xlsx"
    df, cluster_map = cluster_warning_logs(excel_path, out_path=out_excel)

    train_folder = "your_data_folder/json_training"
    ref_folder   = "your_data_folder/json_reference"
    test_folder  = "your_data_folder/json_testing"

    train_jsons = [os.path.join(train_folder, f) for f in os.listdir(train_folder) if f.endswith(".json")]
    ref_jsons   = [os.path.join(ref_folder,   f) for f in os.listdir(ref_folder)   if f.endswith(".json")]
    test_jsons  = [os.path.join(test_folder,  f) for f in os.listdir(test_folder)  if f.endswith(".json")]

    train_jsons.sort()
    ref_jsons.sort()
    test_jsons.sort()

    print(f"[Info] Train JSON files: {len(train_jsons)}")
    print(f"[Info] Reference JSON files: {len(ref_jsons)}")
    print(f"[Info] Test JSON files: {len(test_jsons)}")

    train_dataset = TFIDFDataset(train_jsons, cluster_map, max_features=512)
    ref_dataset   = TFIDFDataset(ref_jsons,   cluster_map, max_features=512)
    test_dataset  = TFIDFDataset(test_jsons,  cluster_map, max_features=512)

    print(f"[Info] Training set: {len(train_dataset)}, vec_size: {train_dataset.vec_size}")
    print(f"[Info] Reference set: {len(ref_dataset)}, vec_size: {ref_dataset.vec_size}")
    print(f"[Info] Test set: {len(test_dataset)}, vec_size: {test_dataset.vec_size}")

    if len(train_dataset) == 0:
        print("[Error] No valid training JSON file matched cluster_map!")
        exit(0)
    if len(ref_dataset) == 0:
        print("[Error] No valid reference JSON file matched cluster_map!")
        exit(0)
    if len(test_dataset) == 0:
        print("[Error] No valid test JSON file matched cluster_map!")
        exit(0)

    train_loader = DataLoader(train_dataset, batch_size=8, shuffle=True)

    latent_dim = 128
    model = MultiTaskAE(input_dim=train_dataset.vec_size, latent_dim=latent_dim)

    # ---- Train with dynamic batch-wise margin ----
    train_multitask_ae(model, train_loader,
                       epochs=50, lr=0.001,
                       alpha=0.01, beta=0.01,
                       margin_init=1.0,   # initial margin
                       ema_decay=0.9)     # EMA smoothing; set None/1.0 to disable

    # ---- Generate embeddings ----
    ref_loader = DataLoader(ref_dataset, batch_size=8, shuffle=False)
    test_loader = DataLoader(test_dataset, batch_size=8, shuffle=False)
    ref_emb = generate_embeddings(model, ref_loader, normalize=True)
    test_emb = generate_embeddings(model, test_loader, normalize=True)

    # ---- Similarity ----
    sim_mat = calculate_similarity(test_emb, ref_emb)

    # ---- Visualization ----
    visualize_similarity_matrix_batch(sim_mat, test_jsons, ref_jsons, cluster_map, batch_size=85)

    # ---- Extract top matches ----
    high_thr = 0.98
    n_test = len(test_jsons)
    n_ref = len(ref_jsons)
    best_high_pairs = []
    for i in range(n_test):
        row = sim_mat[i]
        max_score = np.max(row)
        if max_score >= high_thr:
            best_js = np.where(row == max_score)[0]
            j = int(best_js[0])
            base_i = os.path.basename(test_jsons[i]).replace(".json", "")
            base_j = os.path.basename(ref_jsons[j]).replace(".json", "")
            pair_str = f"{base_i}&{base_j}, heatmap: {max_score:.4f}"
            best_high_pairs.append(pair_str)

    extremes_dict = {
        "similar_above_0.98_unique": best_high_pairs
    }
    with open("similarity_extremes.json", "w", encoding="utf-8") as f:
        json.dump(extremes_dict, f, indent=4)
    print("[Info] similarity_extremes.json saved.")

    print("All done with advanced pipeline using train/reference/test split!")
