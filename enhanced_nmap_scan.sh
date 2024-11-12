#!/bin/bash

if [ -z "$1" ]; then
    echo "No OpenAI API Key provided. Please enter your OpenAI API Key:"
    read -s OPENAI_API_KEY
else
    OPENAI_API_KEY="$1"
fi


# Set the network range (change this to match your local network)
NETWORK="192.168.1.0/24"

# Output file for results
OUTPUT_FILE="nmap_scan_results.txt"
GPT_RESULTS_FILE="gpt4_analysis.txt"
RAW_GPT_RESULTS_FILE="raw_gpt4.txt"
> "$OUTPUT_FILE"       # Clear previous nmap results
> "$GPT_RESULTS_FILE"   # Clear previous GPT-4 analysis results
> "$RAW_GPT_RESULTS_FILE"   # Clear previous GPT-4 analysis results

# Step 1: Perform a quick ping scan to discover live hosts
echo "Scanning network for active hosts..."
nmap -sn "$NETWORK" -oG - | awk '/Up$/{print $2}' > live_hosts.txt

# Check if any hosts were found
if [ ! -s live_hosts.txt ]; then
    echo "No active hosts found on the network."
    exit 1
fi

echo "Active hosts found:"
cat live_hosts.txt
echo "----------------------------------------"

# Step 2: Detailed scan for each active host and GPT-4 Analysis
while read -r HOST; do
    echo "Scanning host: $HOST"
    echo "----------------------------------------" >> "$OUTPUT_FILE"
    echo "Host: $HOST" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$OUTPUT_FILE"

    echo "----------------------------------------" >> $RAW_GPT_RESULTS_FILE
    echo "----------------------------------------" >> $RAW_GPT_RESULTS_FILE
    echo "Scanning host: $HOST" >> $RAW_GPT_RESULTS_FILE

    # Run a detailed scan and save the output
    nmap -A "$HOST" -oN temp_scan_result.txt
    cat temp_scan_result.txt >> "$OUTPUT_FILE"

    # Prepare a query summary for GPT-4
    HOST_SCAN_DETAILS=$(<temp_scan_result.txt)
    PROMPT="Given the following nmap scan results for host $HOST, find host type, assess potential security vulnerabilities and list the most relevant findings. Here are the scan details:\n\n$HOST_SCAN_DETAILS\n\n"
    echo "----------------------------------------" >> $RAW_GPT_RESULTS_FILE
    echo "Prompt:" >> $RAW_GPT_RESULTS_FILE
    echo "$PROMPT" >> $RAW_GPT_RESULTS_FILE

    # Step 3: Query GPT-4 API for analysis
    JSON_PAYLOAD=$(jq -n \
        --arg model "gpt-4" \
        --arg role "user" \
        --arg system_content "You are a cybersecurity expert providing analysis of nmap scan results." \
        --arg user_content "$PROMPT" \
        '{
            model: $model,
            messages: [
                {role: "system", content: $system_content},
                {role: $role, content: $user_content}
            ],
            max_tokens: 1000
        }')

    # Query GPT-4 API for analysis
    GPT_RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$JSON_PAYLOAD")

    echo "----------------------------------------" >> $RAW_GPT_RESULTS_FILE
    echo "Response:" >> $RAW_GPT_RESULTS_FILE
    echo $GPT_RESPONSE >> $RAW_GPT_RESULTS_FILE
    

    # Parse and save GPT-4 response
    if [ "$(echo "$GPT_RESPONSE" | jq -r '.error')" == "null" ]; then
        GPT_ANALYSIS=$(echo "$GPT_RESPONSE" | jq -r '.choices[0].message.content')
        echo -e "GPT-4 Analysis for Host $HOST:\n$GPT_ANALYSIS\n" >> "$GPT_RESULTS_FILE"
    else
        echo "Error in GPT-4 response for host $HOST:" >> "$GPT_RESULTS_FILE"
        echo "$GPT_RESPONSE" | jq -r '.error.message' >> "$GPT_RESULTS_FILE"
    fi
    echo "GPT-4 analysis complete for $HOST. Results saved."

    echo "----------------------------------------" >> "$OUTPUT_FILE"
    echo "----------------------------------------" >> "$GPT_RESULTS_FILE"

done < live_hosts.txt

# Final message
echo "Network scan completed. Results saved to $OUTPUT_FILE."
echo "GPT-4 analysis saved to $GPT_RESULTS_FILE."
