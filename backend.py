from flask import Flask, request, jsonify, send_from_directory
import ollama
import requests
import os

app = Flask(__name__)

# Load the Llama-3 model
ollama.pull('llama3')

modelfile = '''
FROM llama3
SYSTEM You are a Text-to-speech chatbot named AiSMR. Speak in a soothing tone, say things that would relax the user and calm them down. Only say 2 short sentences at a time. Don't put asterisks, because the Text-to-speech will read them.
'''

ollama.create(model='newModel', modelfile=modelfile)

# Directory to save audio files
AUDIO_DIRECTORY = os.path.join(os.getcwd(), 'audio_files')
os.makedirs(AUDIO_DIRECTORY, exist_ok=True)  # Create directory for audio files

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_message = data.get('message')
    
    # Get the response from the Llama-3 model
    msgs = [{'role': 'user', 'content': user_message}]
    response = ''
    stream = ollama.chat(model='newModel', messages=msgs, stream=True)
    
    for chunk in stream:
        response += chunk['message']['content']
    
    # Now use the Llama-3 response as the transcript for TTS
    audio_file_path = os.path.join(AUDIO_DIRECTORY, 'output.wav')

    # Call the Cartesia TTS API
    tts_response = requests.post(
        "https://api.cartesia.ai/tts/bytes",
        headers={
            "X-API-Key": "5a4670a2-18ea-454b-9641-5b6ffa1c2014",
            "Cartesia-Version": "2024-06-10",
            "Content-Type": "application/json"
        },
        json={
            "model_id": "sonic-english",
            "transcript": response,  # Use the Llama-3 response as the transcript
            "voice": {
                "mode": "id",
                "id": "03496517-369a-4db1-8236-3d3ae459ddf7"
            },
            "output_format": {
                "container": "wav",
                "encoding": "pcm_f32le",
                "sample_rate": 44100
            }
        },
    )

    # Check the TTS response
    if tts_response.status_code == 200:
        with open(audio_file_path, 'wb') as f:
            f.write(tts_response.content)
        return jsonify({'response': response, 'audio_file': 'output.wav'})
    else:
        return jsonify({'error': 'Failed to generate audio', 'status_code': tts_response.status_code, 'message': tts_response.text})


@app.route('/audio/<path:filename>', methods=['GET'])
def get_audio(filename):
    return send_from_directory(AUDIO_DIRECTORY, filename)

if __name__ == '__main__':
    app.run(debug=True)
