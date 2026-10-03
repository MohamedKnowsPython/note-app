import frappe
from frappe.tests.utils import FrappeTestCase


class TestMyNotes(FrappeTestCase):
    """Unit tests for My Notes DocType and API"""

    def setUp(self):
        frappe.set_user("Administrator")

    def test_create_my_note(self):
        note = frappe.get_doc({
            "doctype": "My Notes",
            "title": "Unit Test Note",
            "content": "Created by unit test",
            "priority": "High",
            "status": "Open",
        }).insert()

        self.assertEqual(note.title, "Unit Test Note")
        self.assertEqual(note.priority, "High")
        self.assertEqual(note.status, "Open")
        self.assertTrue(note.name)

        note.delete()

    def test_list_notes_api(self):
        from note_app.api.notes import create_note, list_notes

        result = create_note(
            title="API Unit Test",
            content="Hello from unit test",
            priority="Medium",
        )
        self.assertEqual(result["title"], "API Unit Test")
        self.assertEqual(result["status"], "Open")

        notes = list_notes(status="Open")
        self.assertTrue(any(n.get("title") == "API Unit Test" for n in notes))

        frappe.delete_doc("My Notes", result["name"])
