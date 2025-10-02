from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Store conversation in memory
conversation = []

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint to verify the API is running."""
    return jsonify({"status": "ok", "message": "Jarvis API is running"}), 200

@app.route('/api/query', methods=['POST'])
def process_query():
    """Process a query from the user and return a response."""
    try:
        data = request.json
        if not data or 'query' not in data:
            return jsonify({"status": "error", "message": "No query provided"}), 400
        
        user_query = data['query']
        
        # Add the user message to the conversation
        conversation.append({"role": "user", "content": user_query})
        
        # Process the query (simple response for now)
        response = generate_response(user_query)
        
        # Add the assistant's response to the conversation
        conversation.append({"role": "assistant", "content": response})
        
        return jsonify({"status": "success", "response": response}), 200
    
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/conversation', methods=['GET'])
def get_conversation():
    """Return the entire conversation history."""
    return jsonify({"status": "success", "conversation": conversation}), 200

@app.route('/api/clear', methods=['POST'])
def clear_conversation():
    """Clear the conversation history."""
    global conversation
    conversation = []
    return jsonify({"status": "success", "message": "Conversation cleared"}), 200

def generate_response(query):
    """Generate a response to the user's query."""
    query = query.lower()
    
    # Simple response logic
    if "hello" in query or "hi" in query:
        return "Hello! How can I help you today?"
    
    elif "who are you" in query or "what are you" in query:
        return "I'm Jarvis, your virtual assistant. I'm here to help answer your questions and assist with tasks."
    
    elif "how are you" in query:
        return "I'm functioning well, thank you for asking! How can I assist you today?"
    
    elif "weather" in query:
        return "I'm sorry, I don't have access to real-time weather data at the moment. Would you like me to help with something else?"
    
    elif "time" in query:
        return "I don't have access to your current time. Is there something else I can help with?"
    
    elif "thank" in query:
        return "You're welcome! Is there anything else you'd like help with?"
    
    elif "bye" in query or "goodbye" in query:
        return "Goodbye! Feel free to ask for assistance anytime."
    
    elif "help" in query:
        return "I can answer questions, provide information, or just chat. What would you like to know?"
    
    else:
        return "I'm still learning and don't have a specific answer for that query. Is there something else I can help with?"

if __name__ == '__main__':
    # Get the port from environment variable or use 5000 as default
    port = int(os.environ.get('PORT', 5000))
    
    # Run the Flask app
    print(f"Starting Jarvis API server on http://localhost:{port}")
    app.run(host='0.0.0.0', port=port, debug=True) 