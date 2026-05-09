# -*- coding: utf-8 -*-
import os
import time
import requests
import json

# =====================
# 1. Configuration Section
# =====================
# Set API credentials and endpoint for model access
api_key = "xxxxxxx"
api_base = "https://api."

# Path to the .txt file listing the filenames (line by line) for the control group NO RAG file pairs
txt_file_path = r"/path/pair_Data.txt"

# Path to the parsed file containing mappings: filename -> error types
parsed_file_path = r"/path/mapping.txt"

# Folder containing the original Verilog source files
source_folder = r"/path/source_code" # Modify to the actual path when using

# Mapping from error type to (prompt file path, output file suffix)
ERROR_PROMPT_MAP = {
    "ACNCPI": (r"/path/No_RAG_Prompt_acncpi.txt", "_corrected_acn.v"), # Modify to the actual path when using
    "CLKNPI": (r"/path/No_RAG_Prompt_clknpi.txt", "_corrected_clk.v"), # Modify to the actual path when using
    "FFCKNP": (r"/path/No_RAG_Prompt_ffcknp.txt", "_corrected_ffck.v"), # Modify to the actual path when using
    "CDFDAT": (r"/path/No_RAG_Prompt_cdfdat.txt", "_corrected_cdf.v"), # Modify to the actual path when using
}

output_folder = r"/path/folder_A" # Modify to the actual path when using

# =====================
# 2. Utility Functions
# =====================
def remove_code_fences(text: str) -> str:
    """Remove Markdown code block markers such as ```verilog or ```."""
    fenced_markers = ["```verilog", "```"]
    clean_text = text
    for marker in fenced_markers:
        clean_text = clean_text.replace(marker, "")
    return clean_text.strip()

# Send a prompt to the LLM API with retry and timeout support
#You can change the llm-api configuration as needed
def query_llm(prompt, model="o1", max_tokens=16000, temperature=1, retries=3, timeout=120):
    """
    Query the LLM API with the given prompt.
    Retries on timeout or server errors.
    """
    if model == "o1":
        temperature = 1

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }

    data = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "stream": False
    }
    if model != "o1":
        data["temperature"] = temperature

    for attempt in range(retries):
        try:
            response = requests.post(API_BASE, headers=headers, data=json.dumps(data), timeout=timeout)
            if response.status_code == 200:
                response_data = response.json()
                text_out = response_data["choices"][0]["message"]["content"].strip()
                return text_out
            elif response.status_code in [524, 500]:
                print(f"API Timeout/Server Error {response.status_code}, retry {attempt+1}/{retries}...")
            else:
                print(f"API Error {response.status_code}: {response.text}")
                return None
        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}, retry {attempt+1}/{retries}...")

        time.sleep(5)

    print("Failed after multiple attempts, returning None.")
    return None

# =====================
# 3. Main Workflow
# =====================
def main():
    # Create the output directory if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Step 1: Read parsed error file to build a mapping: filename -> list of error types
    filename_to_errors = {}
    with open(parsed_file_path, "r", encoding="utf-8") as pf:
        for line in pf:
            line = line.strip()
            if not line:
                continue
            # Format: "1745: CLKNPI"
            parts = line.split(":")
            if len(parts) != 2:
                continue
            fn_str = parts[0].strip()
            err_type = parts[1].strip()

            if fn_str not in filename_to_errors:
                filename_to_errors[fn_str] = []
            filename_to_errors[fn_str].append(err_type)

    # Step 2: Read filenames from txt_file_path
    with open(txt_file_path, "r", encoding="utf-8") as f:
        lines = [line.strip() for line in f if line.strip()]

    # Step 3: Process each filename
    for filename_str in lines:
        v_file_name = filename_str + ".v"
        v_file_path = os.path.join(source_folder, v_file_name)

        # Skip if Verilog file does not exist
        if not os.path.exists(v_file_path):
            print(f"Warning: {v_file_path} not found, skip.")
            continue

        # Skip if no error record exists for this filename
        if filename_str not in filename_to_errors:
            print(f"Warning: {filename_str} not found in {parsed_file_path}, skip.")
            continue

        # Read the original Verilog source code
        with open(v_file_path, "r", encoding="utf-8") as vf:
            verilog_code = vf.read()

        # Get all error types associated with this file
        error_types = filename_to_errors[filename_str]

        # Step 4: For each error type, call the LLM API
        for err_type in error_types:
            if err_type not in ERROR_PROMPT_MAP:
                print(f"Error type {err_type} not in ERROR_PROMPT_MAP, skip.")
                continue

            prompt_file, suffix = ERROR_PROMPT_MAP[err_type]
            if not os.path.exists(prompt_file):
                print(f"Prompt file {prompt_file} not found, skip {filename_str}.")
                continue

            # Read the error-specific prompt file
            with open(prompt_file, "r", encoding="utf-8") as pf:
                error_prompt_text = pf.read()

            # Construct the full prompt
            prompt_text = (
                f"{error_prompt_text}\n\n"
                f"Below is the original Verilog code:\n{verilog_code}\n\n"
                "Please fix the errors in the code above. "
                "Generate to me the complete modified code directly. "
                "Directly output only the corrected Verilog code (eg: module ... endmodule) with no extra human word explanation. "
                "I don't need any text explanation or analysis from you. I just need the complete code!!!\n\n"
            )

            # Query the LLM
            #You can change the llm-api configuration as needed
            response_text = query_llm(prompt_text, model="o1", max_tokens=16000, temperature=1)
            if not response_text:
                print(f"Skipping {filename_str} for error type {err_type} (API failure).")
                continue

            # Clean the returned code
            cleaned_code = remove_code_fences(response_text).strip()

            # Basic format check
            if not (cleaned_code.startswith("module") and cleaned_code.endswith("endmodule")):
                print(f"Warning: {filename_str} for {err_type} not in module...endmodule format.")

            # Construct output filename and path
            corrected_filename = filename_str + suffix
            corrected_filepath = os.path.join(output_folder, corrected_filename)

            # Save the corrected Verilog file
            with open(corrected_filepath, "w", encoding="utf-8") as out_f:
                out_f.write(cleaned_code)

            print(f"Saved corrected file: {corrected_filepath}")

if __name__ == "__main__":
    main()
