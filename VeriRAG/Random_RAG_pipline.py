# -*- coding: utf-8 -*-
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

# Define paths to background knowledge, source and answer Verilog files, target list, and output folder
background_info_path = r"/path/Random_RAG_prompt.txt" # Modify to the actual path when using
source_code_folder = r"/path/source_code" # Modify to the actual path when using
ans_code_folder = r"/path/ans_code" # Modify to the actual path when using
dpair_list_path = r"/path/Random_pair_Data.txt" # Modify to the actual path when using
output_folder = r"/path/folder_A" # Modify to the actual path when using

# Initialize conversation memory 
memory = ConversationBufferMemory(memory_key="chat_history")

# Read background information about DFT rules and practices
def read_text_file(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read().strip()

# Read Verilog source code from a file
def read_verilog_code(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        return file.read()

# Remove markdown-style code fences (```verilog) that interfere with compilation
def remove_code_fences(text: str) -> str:
    fenced_markers = ["```verilog", "```"]
    clean_text = text
    for marker in fenced_markers:
        clean_text = clean_text.replace(marker, "")
    return clean_text.strip()

# Execute the HAL tool to validate and compile Verilog code
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

# Send a prompt to the LLM API with retry and timeout support
#You can change the llm-api configuration as needed
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
        "stream": False
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

#You can change the llm-api configuration as needed
def best_rag_fix(model="gpt-4o", temperature=0.7):
    max_tokens = 16000

# Read background information about DFT rules and practices
    dft_background_info = read_text_file(background_info_path)

# Randomly select a Verilog file from the source_code folder
    source_files = [f for f in os.listdir(source_code_folder) if f.endswith(".v")]
    selected_source_file = random.choice(source_files)

# Read the corresponding ans file
    ans_file_path = os.path.join(ans_code_folder, selected_source_file)
    source_file_path = os.path.join(source_code_folder, selected_source_file)

    if not os.path.exists(ans_file_path):
        print(f"Warning: Missing answer code for {selected_source_file}")
        return

    reference_source_code = read_verilog_code(source_file_path)
    reference_answer_code = read_verilog_code(ans_file_path)

# Read the list of Verilog target files that need to be repaired
    with open(modification_list_path, "r", encoding="utf-8") as file:
        modification_files = [line.strip() + ".v" for line in file.readlines()]

    for mod_file in modification_files:
        mod_file_path = os.path.join(source_code_folder, mod_file)
        if not os.path.exists(mod_file_path):
            print(f"Warning: {mod_file} not found in source_code folder.")
            continue
        
        target_verilog_code = read_verilog_code(mod_file_path)

# First LLM interaction using reference code pair and new target code
        prompt = (
            f"Here is the DFT background knowledge:\n{dft_background_info}\n\n"
            f"Below is a reference source code with errors not modified:\nverilog\n{reference_source_code}\n\n"
            f"Below is the corresponding corrected answer code:\nverilog\n{reference_answer_code}\n\n"
            f"Now, please modify a new Verilog code file:\nverilog\n{target_verilog_code}\n\n"
            "Based on the given background knowledge and reference examples, provide the corrected Verilog code only, with no explanations.Directly output only the corrected Verilog code (eg: module ... endmodule) with no extra human word explanation. I don't need any text explanation or analysis from you. I just need the complete code!!!\n\n"
        )

        modified_code = query_llm(prompt, model=model, max_tokens=max_tokens, temperature=temperature)
        if not modified_code:
            print(f"Skipping {mod_file} due to API failure.")
            continue

# Save the first generated fix by the LLM
        output_file_path = os.path.join(output_folder, mod_file.replace(".v", "_corrected.v"))
        with open(output_file_path, "w", encoding="utf-8") as output_file:
            output_file.write(modified_code)
        print(f"Modified Verilog saved: {output_file_path}")

# Loop up to 5 times: validate code using HAL, provide feedback to LLM, and iterate
        iteration = 1
        max_iterations = 5
        while iteration <= max_iterations:
            success, hal_output = run_hal_check(output_file_path)
            if success:
                print(f"{mod_file} passed verification.")
                break

# If HAL fails, construct a new prompt using previous result and HAL feedback
            last_modified_code = read_verilog_code(output_file_path)
            prompt = (
                f"Here is the DFT background knowledge:\n{dft_background_info}\n\n"
                f"Below is a reference source code with errors not modified:\nverilog\n{reference_source_code}\n\n"
                f"Below is the corresponding corrected answer code:\nverilog\n{reference_answer_code}\n\n"
                f"The previous modification attempt for {mod_file} (content below) failed HAL testing with these errors:\n{hal_output}\n\n"
                f"The last version of the code that I want you to correct was:\nverilog\n{last_modified_code}\n\n"
                "Please correct the errors and provide updated Verilog code only, with no word explanations!Directly output only the corrected Verilog code (eg: module ... endmodule) with no extra human word explanation. I don't need any text explanation or analysis from you. I just need the complete code!!!\n\n"
            )

            modified_code = query_llm(prompt, model=model, max_tokens=max_tokens, temperature=temperature)
            if not modified_code:
                print(f"Skipping {mod_file} due to API failure.")
                break

            new_file_path = os.path.join(output_folder, mod_file.replace(".v", f"_corrected_{iteration}.v"))
            with open(new_file_path, "w", encoding="utf-8") as output_file:
                output_file.write(modified_code)
            print(f"Modified Verilog saved: {new_file_path}")

            output_file_path = new_file_path
            iteration += 1
            time.sleep(10)

        if iteration > max_iterations:
            print(f"Max iteration limit ({max_iterations}) reached for {mod_file}. Skipping further retries.")

# You can change the llm-api configuration as needed
if __name__ == "__main__":
    best_rag_fix(model="gpt-4o", temperature=0.7)
