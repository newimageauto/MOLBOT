#!/bin/bash
set -e

echo "========================================"
echo "🤖 MOLBOT AGENT RUNTIME v2.0"
echo "========================================"

# Start the base desktop/VNC services that come with the image

/startup.sh &
sleep 10

# Wait for env vars (spawn-server injects these after deploy)

if [ -z "$SUPABASE_URL" ] || [ -z "$AGENT_ID" ]; then
echo "❌ Missing required environment variables"
echo "   SUPABASE_URL: ${SUPABASE_URL:-NOT SET}"
echo "   AGENT_ID: ${AGENT_ID:-NOT SET}"
echo "Waiting for env vars..."
for i in $(seq 1 12); do
sleep 5
if [ -n "$SUPABASE_URL" ] && [ -n "$AGENT_ID" ]; then
echo "✓ Environment variables ready"
break
fi
echo "   Attempt $i/12..."
done
fi

echo "🧠 Downloading agent runtime..."
curl -sL "${SUPABASE_URL}/functions/v1/serve-brain" -o /home/ubuntu/agent.py

cat > /home/ubuntu/run-agent.sh << 'EOF'
#!/bin/bash
source /opt/molbot-env/bin/activate
cd /home/ubuntu
python3 agent.py
EOF
chmod +x /home/ubuntu/run-agent.sh

echo "🚀 Starting agent..."
source /opt/molbot-env/bin/activate
cd /home/ubuntu
python3 agent.py &

# Keep container alive

tail -f /dev/null
