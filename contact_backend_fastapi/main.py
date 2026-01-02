from pymongo import MongoClient
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from schemas import Contact
from models import (
    get_all_contacts,
    add_contact,
    update_contact,
    delete_contact
)
import uvicorn

MONGO_URL = "mongodb://127.0.0.1:27017"
client = MongoClient(MONGO_URL)
db = client["contacts_db"]
contact_collection = db["contacts"]

app = FastAPI(title="Contact Manager API")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Contact Manager API is running"}

@app.get("/contacts")
def get_contacts():
    try:
        contacts = get_all_contacts()
        print(f"✅ GET /contacts - Returning {len(contacts)} contacts")
        return contacts
    except Exception as e:
        print(f"❌ GET /contacts error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/contacts", status_code=201)
def create_contact(contact: Contact):
    try:
        print(f"✅ POST /contacts - Creating contact: {contact.name}")
        contact_data = contact.dict(exclude={"id"})
        return add_contact(contact_data)
    except Exception as e:
        print(f"❌ POST /contacts error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.put("/contacts/{contact_id}")
def modify_contact(contact_id: str, contact: Contact):
    try:
        print(f"✅ PUT /contacts/{contact_id}")
        data = {
            k: v for k, v in contact.dict().items()
            if v is not None and k != "id"
        }
        updated = update_contact(contact_id, data)
        if not updated:
            raise HTTPException(status_code=404, detail="Contact not found")
        return updated
    except Exception as e:
        print(f"❌ PUT /contacts/{contact_id} error: {e}")
        raise

@app.delete("/contacts/{contact_id}")
def remove_contact(contact_id: str):
    try:
        print(f"✅ DELETE /contacts/{contact_id}")
        deleted = delete_contact(contact_id)
        if deleted == 0:
            raise HTTPException(status_code=404, detail="Contact not found")
        return {"message": "Contact deleted"}
    except Exception as e:
        print(f"❌ DELETE /contacts/{contact_id} error: {e}")
        raise

if __name__ == "__main__":
    print("🚀 Starting Contact Manager API on http://localhost:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)

