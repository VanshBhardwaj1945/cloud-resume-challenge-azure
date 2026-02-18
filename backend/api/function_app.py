import os
import json
import logging

import azure.functions as func
from azure.cosmos import CosmosClient

# Read connection details from environment (local.settings.json for local dev).
# Make sure these point to the exact Cosmos account / DB / container in the portal.
COSMOS_CONN_STR = os.environ["COSMOSDB_CONNECTION_STRING"]
DATABASE_NAME = os.environ.get("COSMOS_DATABASE", "counter")       # exact database id
CONTAINER_NAME = os.environ.get("COSMOS_CONTAINER", "visitorcount")# exact container id

# Create a Cosmos client once at import. This is cheap and reused across calls.
client = CosmosClient.from_connection_string(COSMOS_CONN_STR)

# Azure Functions app instance (HTTP-triggered function)
app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

@app.route(route="getResumeCounter", methods=["GET"])
def getResumeCounter(req: func.HttpRequest) -> func.HttpResponse:
 
    logging.info("Visitor counter function processed a request.")

    # Get database and container clients (assumes they already exist)
    db = client.get_database_client(DATABASE_NAME)
    container = db.get_container_client(CONTAINER_NAME)

    # Read the single counter document. This will raise if the item does not exist.
    counter_doc = container.read_item(item="counter", partition_key="counter")

    # Read current count, increment, update document
    count = counter_doc.get("count", 0) + 1
    counter_doc["count"] = count

    # Save updated document back to Cosmos
    container.upsert_item(counter_doc)

    # Return JSON in the shape the frontend expects
    return func.HttpResponse(
        json.dumps({"count": count}),
        status_code=200,
        mimetype="application/json"
    )

# CI/CD workflow check