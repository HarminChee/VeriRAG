# -*- coding: utf-8 -*-
# Import required libraries for API access, file operations, subprocesses, and LangChain memory
import openai
import os
import time
import random
import requests
import json
import subprocess
from langchain.memory import ConversationBufferMemory

# Set API credentials and endpoint for model access
api_key = "xxxxxxx"
api_base = "https://api."

# Configure paths to DFT background info, Verilog code folders, and output folders
background_info_path = r"/path/VeriRAG_prompt.txt" # Modify to the actual path when using
source_code_folder = r"/path/source_code" # Modify to the actual path when using
ans_code_folder = r"/path/ans_code" # Modify to the actual path when using
dpair_list_path = r"/path/VeriRAG_pair_Data.txt" # Modify to the actual path when using
output_folder = r"/path/folder_A" # Modify to the actual path when using

# Initialize conversation memory for LangChain (not actively used in this script)
memory = ConversationBufferMemory(memory_key="chat_history")

# Read plain text content from a specified file
def read_text_file(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read().strip()

# Read raw Verilog source code from a file
def read_verilog_code(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read()

# Remove markdown code fences that could interfere with Verilog compilation
def remove_code_fences(text: str) -> str:
    fenced_markers = ["```verilog", "```"]
    clean_text = text
    for marker in fenced_markers:
        clean_text = clean_text.replace(marker, "")
    return clean_text.strip()

# Run external 'hal' tool to validate Verilog code syntax and compilation status
def run_hal_check(verilog_file):
    try:
        output = subprocess.check_output(["hal", verilog_file, "-sv"], stderr=subprocess.STDOUT, text=True)
        print(f"HAL Output for {verilog_file}:\n{output}")
        
        if "Analysis complete" in output:
            return True, output  
        elif "Analysis failed" in output:
            return False, output  
        else:
            return False, "Unknown error"
    except subprocess.CalledProcessError as e:
        return False, e.output  

# Query the LLM API with retry logic and proper headers for chat-based interaction
def query_llm(prompt, model="gpt-4o", max_tokens=16000, temperature=0.7, retries=3, timeout=120):
    if model == "o1":
        temperature = 1

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    data = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": max_tokens,
        "stream": True
    }
    if model != "o1":
        data["temperature"] = temperature

    session = requests.Session()
    for attempt in range(retries):
        try:
            response = session.post(api_base, headers=headers, data=json.dumps(data), timeout=timeout)
            if response.status_code == 200:
                response_data = response.json()
                text_out = response_data["choices"][0]["message"]["content"].strip()
                text_out = remove_code_fences(text_out)
                return text_out
            elif response.status_code in [524, 500]:
                print(f"API Timeout or Server Error ({response.status_code}), Retrying {attempt+1}/{retries}...")
            else:
                print(f"API Error {response.status_code}: {response.text}")
                return None
        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}, Retrying {attempt+1}/{retries}...")
        time.sleep(10)
    print("Failed after multiple attempts, skipping request.")
    return None

# Generate a unique file path to avoid overwriting existing output files
def unique_file_path(base_path):

    if not os.path.exists(base_path):
        return base_path
    
    filename, ext = os.path.splitext(base_path)
    i = 1
    new_path = f"{filename}({i}){ext}"
    while os.path.exists(new_path):
        i += 1
        new_path = f"{filename}({i}){ext}"
    return new_path

# You can change the llm-api configuration as needed
def best_rag_fix_d(model="gpt-4o", temperature=0.7):
    max_tokens = 16000

    dft_background_info = read_text_file(background_info_path)

    with open(dpair_list_path, "r", encoding="utf-8") as dpair_file:
        dpairs = [line.strip() for line in dpair_file.readlines() if "&" in line]

    for pair_line in dpairs:
        
        ref_part, tar_part = pair_line.split("&")
        ref_part = ref_part.strip()
        tar_part = tar_part.strip()

        ref_file = ref_part + ".v"
        tar_file = tar_part + ".v"

        
        pair_label_1 = f"pair{ref_part}-{tar_part}"
        pair_label_2 = f"pair{tar_part}-{ref_part}"

        ref_path = os.path.join(source_code_folder, ref_file)
        ans_path = os.path.join(ans_code_folder, ref_file)
        tar_path = os.path.join(source_code_folder, tar_file)

        if not (os.path.exists(ref_path) and os.path.exists(ans_path) and os.path.exists(tar_path)):
            print(f"Warning: {pair_line} not found in source_code or ans_code folder.")
            continue

        
        do_fix_once(
            ref_file=ref_path,
            ans_file=ans_path,
            target_file=tar_path,
            ref_name=ref_part,
            tar_name=tar_part,
            dft_background=dft_background_info,
            model=model,
            max_tokens=max_tokens,
            temperature=temperature,
            pair_label=pair_label_1
        )

        
        tar_path_2 = os.path.join(source_code_folder, ref_file)  
        ans_path_2 = os.path.join(ans_code_folder, tar_file)     
        if not os.path.exists(ans_path_2):
            print(f"Warning: Missing answer code for reversed ref: {tar_file}")
            continue

        do_fix_once(
            ref_file=tar_path,
            ans_file=ans_path_2,
            target_file=ref_path,
            ref_name=tar_part,
            tar_name=ref_part,
            dft_background=dft_background_info,
            model=model,
            max_tokens=max_tokens,
            temperature=temperature,
            pair_label=pair_label_2
        )

# Execute one LLM-driven code correction followed by HAL-based verification loop
def do_fix_once(
    ref_file, ans_file, target_file,
    ref_name, tar_name,
    dft_background, model, max_tokens, temperature,
    pair_label
):
    reference_source_code = read_verilog_code(ref_file)
    reference_answer_code = read_verilog_code(ans_file)
    target_verilog_code = read_verilog_code(target_file)

    # First interaction
    prompt = (
        f"Here is the DFT background knowledge:\n{dft_background}\n\n"
        f"Below is a reference source code with errors not modified:\nverilog\n{reference_source_code}\n\n"
        f"Below is the corresponding corrected answer code:\nverilog\n{reference_answer_code}\n\n"
        f"Now, based on the reference code pairs, please modify a similar new Verilog code file:\nverilog\n{target_verilog_code}\n\n"
        "Based on the given background knowledge and reference examples, provide the corrected Verilog code only, with no explanations.Directly output only the corrected Verilog code (eg: module ... endmodule) with no extra human word explanation. I don't need any text explanation or analysis from you. I just need the complete code!!!\n\n"
    )

    modified_code = query_llm(prompt, model=model, max_tokens=max_tokens, temperature=temperature)
    if not modified_code:
        print(f"Skipping fix for {tar_name} due to API failure.")
        return

    # Save the first modification and add pair_label
    # e.g. "45083_pair14299-45083_corrected.v"
    base_corrected = os.path.join(output_folder, f"{tar_name}_{pair_label}_corrected.v")
    output_file_path = unique_file_path(base_corrected)
    with open(output_file_path, "w", encoding="utf-8") as output_file:
        output_file.write(modified_code)
    print(f"Modified Verilog saved: {output_file_path}")

    iteration = 1
    max_iterations = 5
    while iteration <= max_iterations:
        success, hal_output = run_hal_check(output_file_path)
        if success:
            print(f"{tar_name} passed verification.")
            break

        # Failure => Continue interaction
        last_modified_code = read_verilog_code(output_file_path)
        prompt = (
            f"Here is the DFT background knowledge:\n{dft_background}\n\n"
            f"Below is a reference similar source code with errors not modified:\nverilog\n{reference_source_code}\n\n"
            f"Below is the corresponding corrected answer code:\nverilog\n{reference_answer_code}\n\n"
            f"The previous modification attempt for {tar_name} (content below) failed HAL testing with these errors:\n{hal_output}\n\n"
            f"The last version of the code that I want you to correct was:\nverilog\n{last_modified_code}\n\n"
            "Please correct the errors and provide updated Verilog code only, with no explanations.Directly output only the corrected Verilog code (eg: module ... endmodule) with no extra human word explanation. I don't need any text explanation or analysis from you. I just need the complete code!!!\n\n"
        )

        modified_code = query_llm(prompt, model=model, max_tokens=max_tokens, temperature=temperature)
        if not modified_code:
            print(f"Skipping fix for {tar_name} due to API failure.")
            break

        # Save the new revision, also add pair_label
        # e.g. "45083_pair14299-45083_corrected_1.v"
        base_retry = os.path.join(output_folder, f"{tar_name}_{pair_label}_corrected_{iteration}.v")
        new_file_path = unique_file_path(base_retry)
        with open(new_file_path, "w", encoding="utf-8") as output_file:
            output_file.write(modified_code)
        print(f"Modified Verilog saved: {new_file_path}")

        output_file_path = new_file_path
        iteration += 1
        time.sleep(10)

    if iteration > max_iterations:
        print(f"Max iteration limit ({max_iterations}) reached for {tar_name}. Skipping further retries.")
        
# You can change the llm-api configuration as needed
if __name__ == "__main__":
    best_rag_fix_d(model="gpt-4o", temperature=0.7)
