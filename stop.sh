#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🔥 Deleting Kind cluster..."
kind delete cluster --name kube-playground
echo "✅ Cleanup complete!"
