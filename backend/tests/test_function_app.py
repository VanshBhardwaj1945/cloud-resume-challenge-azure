import os
import json
from unittest.mock import patch, MagicMock

os.environ["COSMOSDB_CONNECTION_STRING"] = "AccountEndpoint=https://fake.documents.azure.com:443/;AccountKey=fakekey;"
os.environ["COSMOS_DATABASE"] = "counter"
os.environ["COSMOS_CONTAINER"] = "visitorcount"


with patch("azure.cosmos.CosmosClient") as MockCosmosClient:
    mock_client_instance = MagicMock()
    MockCosmosClient.from_connection_string.return_value = mock_client_instance

    mock_db = MagicMock()
    mock_container = MagicMock()
    mock_client_instance.get_database_client.return_value = mock_db
    mock_db.get_container_client.return_value = mock_container

    mock_container.read_item.return_value = {"id": "counter", "count": 5}
    mock_container.upsert_item.return_value = None

    from api.function_app import getResumeCounter

def test_getResumeCounter_increments():
   

    mock_req = MagicMock()
    # Create a fake HTTP request object. We don’t care about the real request here,
    # we just need something to pass to our function so it can run.

    resp = getResumeCounter(mock_req)
    # Call the function we’re testing (getResumeCounter) with the fake request.
    # This simulates someone hitting the API endpoint.

    assert resp.status_code == 200
    # Check that the function returned a successful HTTP response (status code 200 OK).
    
    data = json.loads(resp.get_body())
    print("Json Data:", data)
    # Convert the function’s JSON response body into a Python dictionary
    # so we can inspect the values inside it. 
   
    
    assert data["count"] == 6
    # Verify that the "count" field in the response is 6. (was initalized as 5)
    # This checks that the function correctly incremented or returned the expected counter.

    mock_container.upsert_item.assert_called_once()
    # Make sure that our fake Cosmos container had its 'upsert_item' method called exactly once.
    # This confirms that the function tried to save the updated counter back to the database.