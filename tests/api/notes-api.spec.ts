import { test, expect } from '@playwright/test';

test.describe('My Notes API Chaining', () => {
  let createdNoteName: string;

  test('Create → List → Filter by Status', async ({ request }) => {
    // ========== LOGIN FIRST ==========
    const loginRes = await request.post('/api/method/login', {
      data: {
        usr: 'Administrator',
        pwd: 'admin'          // change if your password is different
      }
    });
    expect(loginRes.ok()).toBeTruthy();
    console.log('Logged in successfully');

    // ========== 1. CREATE NOTE ==========
    const createRes = await request.post('/api/method/note_app.api.notes.create_note', {
      data: {
        title: 'Playwright API Chain Note',
        content: 'Created via Playwright API test',
        priority: 'High'
      }
    });

    // Debug if it still fails
    if (!createRes.ok()) {
      console.log('Create failed. Status:', createRes.status());
      console.log('Response:', await createRes.text());
    }

    expect(createRes.ok()).toBeTruthy();
    const created = await createRes.json();
    createdNoteName = created.message?.name || created.name || created.message;
    console.log('Created note:', createdNoteName);
    expect(createdNoteName).toBeTruthy();

    // ========== 2. LIST ALL NOTES ==========
    const listRes = await request.get('/api/method/note_app.api.notes.list_notes');
    expect(listRes.ok()).toBeTruthy();
    const allNotes = await listRes.json();
    const notes = allNotes.message || allNotes;
    expect(Array.isArray(notes)).toBeTruthy();
    expect(notes.some((n: any) => n.name === createdNoteName || n.title === 'Playwright API Chain Note')).toBeTruthy();

    // ========== 3. FILTER BY STATUS ==========
    const filterRes = await request.get('/api/method/note_app.api.notes.list_notes?status=Open');
    expect(filterRes.ok()).toBeTruthy();
    const openNotesRaw = await filterRes.json();
    const openNotes = openNotesRaw.message || openNotesRaw;
    expect(openNotes.some((n: any) => n.name === createdNoteName || n.title === 'Playwright API Chain Note')).toBeTruthy();
  });
});
