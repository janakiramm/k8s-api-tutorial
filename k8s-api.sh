## Make sure you have access to a Kubernetes cluster
## Install JQ from https://stedolan.github.io/jq/ before running the commands

# Verify Kubernetes setup
kubectl cluster-info
kubectl component-status

# Configure the proxy
kubectl proxy --port=8000&

# Open the url in any browser to access Swagger
open http://localhost:8000/swagger-ui/

# Invoke simple Kubernetes API
curl http://localhost:8000/api

# cURL command equivalent to 'kubectl get nodes'
curl -s http://localhost:8000/api/v1/nodes | jq '.items[] .metadata.labels'

# Create a Nginx Pod definition
cat > nginx-pod.json <<EOF
{
    "kind": "Pod",
    "apiVersion": "v1",
    "metadata":{
        "name": "nginx",
        "namespace": "default",
        "labels": {
            "name": "nginx"
        }
    },
    "spec": {
        "containers": [{
            "name": "nginx",
            "image": "nginx",
            "ports": [{"containerPort": 80}],
            "resources": {
                "limits": {
                    "memory": "128Mi",
                    "cpu": "500m"
                }
            }
        }]
    }
}
EOF

# Create a Service definition to expose Nginx Pod
cat > nginx-service.json <<EOF
{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "nginx-service",
        "namespace": "default",
        "labels": {"name": "nginx"}
    },
    "spec": {
        "ports": [{"port": 80}],
        "selector": {"name": "nginx"}
    }
}
EOF

# Create the Pod object
curl -s http://localhost:8000/api/v1/namespaces/default/pods \
-XPOST -H 'Content-Type: application/json' \
-d@nginx-pod.json \
| jq '.status'

# Create the Service object
curl -s http://localhost:8000/api/v1/namespaces/default/services \
-XPOST -H 'Content-Type: application/json' \
-d@nginx-service.json \
| jq '.spec.clusterIP'

# Verify the Pod with 'kubectl get pods'
kubectl get pods

# Verify the Service with 'kubectl get svc'
kubectl get svc

# Access Nginx default page through the proxy
curl http://localhost:8000/v1/proxy/namespaces/default/services/nginx-service/

# Delete the Pod
curl http://localhost:8000/api/v1/namespaces/default/services/nginx-service -XDELETE

# Delete the Service
curl http://localhost:8000/api/v1/namespaces/default/pods/nginx -XDELETE


