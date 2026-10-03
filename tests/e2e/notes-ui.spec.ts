import { test, expect } from '@playwright/test';

test.describe('My Notes UI E2E', () => {
  test.beforeEach(async ({ page }) => {
    console.log('STEP 1: Logging in as Administrator');
    await page.goto('/login');
    await page.fill('#login_email', 'Administrator');
    await page.fill('#login_password', 'admin');
    await page.click('.btn-login');
    await page.waitForURL('**/app**');
    await page.waitForTimeout(2000);
  });

  test('Create a My Note from UI', async ({ page }) => {
    // STEP 2: Navigate to My Notes
    console.log('STEP 2: Searching for My Notes via Awesome Bar');
    await page.click('#navbar-search, .navbar-search, input[placeholder*="Search"], .search-bar');
    await page.waitForTimeout(800);
    await page.keyboard.type('My Notes');
    await page.waitForTimeout(1000);
    await page.keyboard.press('Enter');

    await page.waitForURL('**/app/my-notes**');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    console.log('STEP 2: Successfully landed on My Notes list');

    // STEP 3: Click Add My Notes
    console.log('STEP 3: Clicking "Add My Notes" button');
    await page.click('button:has-text("Add My Notes"), span:has-text("Add My Notes")');
    
    await page.waitForURL('**/app/my-notes/new-my-notes-**');
    await page.waitForTimeout(2000);
    console.log('STEP 3: New My Notes form opened');

    // STEP 4: Fill Title
    console.log('STEP 4: Filling Title field');
    await page.fill('[data-fieldname="title"] input', 'E2E UI Note from Playwright');
    await page.waitForTimeout(800);

    // STEP 5: Fill Content
    console.log('STEP 5: Filling Content field');
    const content = page.locator('[data-fieldname="content"] textarea, [data-fieldname="content"] .ql-editor');
    if (await content.count() > 0) {
      await content.first().fill('This note was created by Playwright E2E test');
    }
    await page.waitForTimeout(800);

    // STEP 6: Set Priority
    console.log('STEP 6: Setting Priority to High');
    const prioritySelect = page.locator('select[data-fieldname="priority"]');
    if (await prioritySelect.count() > 0) {
      await prioritySelect.selectOption({ label: 'High' });
    }
    await page.waitForTimeout(800);

    // STEP 7: Save
    console.log('STEP 7: Clicking Save button');
    await page.click('button.primary-action:has-text("Save"), button:has-text("Save")');

    // Wait until saved
    await page.waitForURL(url => !url.pathname.includes('/new-my-notes-'), { timeout: 15000 });
    await page.waitForTimeout(2000);

    console.log('STEP 8: Note saved successfully');
    await expect(page).not.toHaveURL(/new-my-notes-/);
    
    console.log('✅ E2E Test completed successfully');
  });
});
