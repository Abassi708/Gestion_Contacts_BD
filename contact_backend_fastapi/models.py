from bson import ObjectId
from database import contact_collection

def contact_helper(contact) -> dict:
    return {
        "id": str(contact["_id"]),
        "name": contact["name"],
        "phone": contact["phone"],
        "email": contact.get("email", ""),
        "address": contact.get("address", ""),
        "notes": contact.get("notes", "")
    }

def get_all_contacts():
    contacts = []
    for contact in contact_collection.find():
        contacts.append(contact_helper(contact))
    return contacts

def add_contact(contact_data: dict):
    result = contact_collection.insert_one(contact_data)
    new_contact = contact_collection.find_one(
        {"_id": ObjectId(result.inserted_id)}
    )
    return contact_helper(new_contact)

def delete_contact(contact_id: str):
    result = contact_collection.delete_one(
        {"_id": ObjectId(contact_id)}
    )
    return result.deleted_count

def update_contact(contact_id: str, data: dict):
    updated = contact_collection.update_one(
        {"_id": ObjectId(contact_id)},
        {"$set": data}
    )
    if updated.matched_count == 0:
        return None
    return contact_helper(
        contact_collection.find_one({"_id": ObjectId(contact_id)})
    )
