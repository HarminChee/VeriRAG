# -*- coding: utf-8 -*-
import os
import requests
import json
import time

# Set API credentials and endpoint for model access
api_key = "xxxxxxx"
api_base = "https://api."

# Text file listing filenames to be processed (one filename per line, e.g., "1234")
txt_file_path = r"/path/pair_Data.txt"

# Folder containing the original Verilog source files
source_folder = r"/path/source_code" # Modify to the actual path when using

# Output directory to store the corrected Verilog files
output_folder = r"/path/folder_A" # Modify to the actual path when using

def remove_code_fences(text: str) -> str:
    """
    Remove markdown-style code block markers such as ```verilog and ``` from the LLM output.
    """
    fenced_markers = ["```verilog", "```"]
    clean_text = text
    for marker in fenced_markers:
        clean_text = clean_text.replace(marker, "")
    return clean_text.strip()

# Send a prompt to the LLM API with retry and timeout support
#You can change the llm-api configuration as needed
def query_llm(prompt, model="o1", max_tokens=16000, temperature=1, retries=3, timeout=120):
    """
    Send a prompt to the LLM API and return the model's output.
    Automatically retries on timeout or server errors.
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

    print("Failed after multiple attempts.")
    return None

def main():
    # Create output directory if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    # Read all filenames from the input txt file (one filename per line)
    with open(txt_file_path, "r", encoding="utf-8") as f:
        lines = [line.strip() for line in f if line.strip()]

    for line in lines:
        # Compose full Verilog filename (e.g., "1234.v")
        verilog_file_name = f"{line}.v"
        verilog_file_path = os.path.join(source_folder, verilog_file_name)

        # Skip if the Verilog file does not exist
        if not os.path.exists(verilog_file_path):
            print(f"Warning: {verilog_file_name} not found.")
            continue

        # Load the original Verilog source code
        with open(verilog_file_path, "r", encoding="utf-8") as vf:
            original_code = vf.read()

        # Construct the prompt for the LLM
        prompt_text = (
            "This is a DFT Verilog test code. It contains design-for-testability errors. "
            "Please correct them and return the fully corrected Verilog code. "
            "Only output the corrected code (e.g., module ... endmodule) with no explanation.\n\n"
            + original_code
        )

        # Call the LLM to get the corrected version
        # You can change the llm-api configuration as needed
        response_text = query_llm(prompt_text, model="o1", max_tokens=16000, temperature=1)
        if not response_text:
            print(f"Skipping {verilog_file_name} due to API error.")
            continue

        # Remove any markdown-style code block markers from the output
        cleaned_code = remove_code_fences(response_text).strip()

        # Basic sanity check for format
        if not (cleaned_code.startswith("module") and cleaned_code.endswith("endmodule")):
            print(f"Warning: Output for {verilog_file_name} is not wrapped with module...endmodule.")

        # Generate output filename (e.g., "1234_corrected.v")
        corrected_file_name = f"{line}_corrected.v"
        corrected_file_path = os.path.join(output_folder, corrected_file_name)

        # Save the corrected code to the output directory
        with open(corrected_file_path, "w", encoding="utf-8") as out_f:
            out_f.write(cleaned_code)

        print(f"Saved corrected file: {corrected_file_path}")

if __name__ == "__main__":
    main()
