import frappe
import pytest
from frappe.tests.utils import FrappeTestCase

class TestMyNotes(FrappeTestCase):
    """Unit tests for My Notes DocType and API"""

    def setUp(self):
        frappe.set_user("Administrator")

    def test_create_my_note(self):
        """
        Test: Creating a new My Notes document
        Should successfully insert a note with title, content and priority
        """
        note = frappe.get_doc({
            "doctype": "My Notes",
            "title": "Unit Test Note",
            "content": "Created by unit test",
            "priority": "High",
            "status": "Open"
        }).insert()

        assert note.title == "Unit Test Note"
        assert note.priority == "High"
        assert note.name is not None

    def test_list_notes_api(self):
        """
        Test: create_note + list_notes API methods
        Should create a note and be able to retrieve it via list_notes
        """
        from note_app.api.notes import create_note, list_notes

        create_note(title="API Unit Test", content="Hello from unit test", priority="Medium")
        notes = list_notes(status="Open")

        assert any(n.get("title") == "API Unit Test" for n in notes)
