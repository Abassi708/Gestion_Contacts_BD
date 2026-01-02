from pydantic import BaseModel
from typing import Optional

class Contact(BaseModel):
    id: Optional[str] = None
    name: str
    phone: str
    email: Optional[str] = ""
    address: Optional[str] = ""
    notes: Optional[str] = ""
