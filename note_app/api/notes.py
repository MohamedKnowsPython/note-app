import frappe
from frappe import _

DOCTYPE = "My Notes"


@frappe.whitelist()
def create_note(title, content=None, priority="Medium"):
    """Create a new My Notes"""
    doc = frappe.get_doc({
        "doctype": DOCTYPE,
        "title": title,
        "content": content or "",
        "status": "Open",
        "priority": priority or "Medium",
    }).insert()
    return {
        "name": doc.name,
        "title": doc.title,
        "status": doc.status,
        "priority": doc.priority,
    }


@frappe.whitelist()
def list_notes(status=None, limit=20):
    """List notes, optionally filtered by status"""
    filters = {}
    if status:
        filters["status"] = status
    return frappe.get_all(
        DOCTYPE,
        filters=filters,
        fields=["name", "title", "status", "priority", "creation", "modified"],
        order_by="creation desc",
        limit_page_length=int(limit or 20),
    )


@frappe.whitelist()
def get_note(name):
    """Get a single note by name"""
    doc = frappe.get_doc(DOCTYPE, name)
    return doc.as_dict()


@frappe.whitelist()
def update_note_status(name, status):
    """Update only the status of a note"""
    doc = frappe.get_doc(DOCTYPE, name)
    doc.status = status
    doc.save()
    return {"name": doc.name, "status": doc.status}


@frappe.whitelist()
def delete_note(name):
    """Delete a note"""
    frappe.delete_doc(DOCTYPE, name)
    return {"message": f"Note {name} deleted"}
