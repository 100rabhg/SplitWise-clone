document.addEventListener('turbolinks:load', () => {
  const container = document.querySelector('#items-container');
  if (!container) return;

  const template = document.querySelector('#item-template');
  const expenseForm = document.querySelector('form');

  // Get a unique index for new items/splits
  const getUniqueIndex = () => new Date().getTime();

  // Get checked participants for splits
  const getCheckedParticipants = () => {
    const checkboxes = document.querySelectorAll('.participant-toggle:checked');
    return Array.from(checkboxes).map(cb => ({
      id: cb.value,
      name: cb.nextElementSibling?.textContent || ''
    }));
  };

  // Create a split row HTML string
  const createSplitRowHtml = (itemIndex, splitIndex, userId, amount = '') => {
    return `
      <div class="row align-items-end mb-2 split-row">
        <div class="col-md-7">
          <label class="form-label small">Participant</label>
          <select class="form-select form-select-sm split-user" required name="expense_transaction[expense_items_attributes][${itemIndex}][item_splits_attributes][${splitIndex}][user_id]">
            <option value="">-- Select user --</option>
          </select>
        </div>
        <div class="col-md-5">
          <label class="form-label small">Share</label>
          <div class="input-group input-group-sm">
            <span class="input-group-text">₹</span>
            <input class="form-control split-amount" required type="number" step="0.01" name="expense_transaction[expense_items_attributes][${itemIndex}][item_splits_attributes][${splitIndex}][amount]" value="${amount}" placeholder="0.00">
            <button class="btn btn-outline-danger remove-split" type="button" title="Remove Split">
              <i class="bi bi-trash"></i>
            </button>
          </div>
        </div>
      </div>
    `;
  };

  // Update all participant dropdowns for splits
  const updateParticipantDropdowns = () => {
    const participants = getCheckedParticipants();
    const allSelects = container.querySelectorAll('.split-user');
    allSelects.forEach(select => {
      const currentValue = select.value;
      select.innerHTML = '<option value="">-- Select user --</option>';
      participants.forEach(p => {
        const option = document.createElement('option');
        option.value = p.id;
        option.textContent = p.name;
        if (p.id === currentValue) {
          option.selected = true;
        }
        select.appendChild(option);
      });
    });
  };

  // Add a new item card (Item/Tax/Tip) to the form
  const addItem = (type = 'Item') => {
    if (!template) {
      console.error("Item template not found!");
      return;
    }
    const index = getUniqueIndex();
    const html = template.innerHTML.replace(/__INDEX__/g, index);
    const frag = document.createElement('div');
    frag.innerHTML = html.trim();
    const card = frag.firstElementChild;

    // Set type for new item
    const typeInput = card.querySelector('input[name*="[type]"]');
    if (typeInput) typeInput.value = type;

    // Hide name field for Tax/Tip and set default name
    if (type !== 'Item') {
      const nameRow = card.querySelector('input[name*="[name]"]');
      if (nameRow) {
        nameRow.parentElement.parentElement.style.display = 'none';
        nameRow.value = type;
      }
    }

    const splitsContainer = card.querySelector('.splits');
    splitsContainer.innerHTML = '';

    // Auto-add splits for each participant
    const participants = getCheckedParticipants();
    participants.forEach(p => {
      const splitIndex = getUniqueIndex() + Math.floor(Math.random() * 1000);
      const rowHtml = createSplitRowHtml(index, splitIndex, p.id);
      const rowFrag = document.createElement('div');
      rowFrag.innerHTML = rowHtml.trim();
      const row = rowFrag.firstElementChild;

      // Preselect participant in split row
      const select = row.querySelector('select');
      const option = document.createElement('option');
      option.value = p.id;
      option.textContent = p.name;
      option.selected = true;
      select.appendChild(option);

      splitsContainer.appendChild(row);
    });

    container.appendChild(card);
    updateParticipantDropdowns();
  };

  const addSplit = (card) => {
    const splitsContainer = card.querySelector('.splits');
    let itemIndex = null;
    const inputs = card.querySelectorAll('input, select');
    for (let inp of inputs) {
      const match = inp.name.match(/\[expense_items_attributes\]\[(\d+)\]/);
      if (match) {
        itemIndex = match[1];
        break;
      }
    }

    if (!itemIndex) {
      console.error("Could not determine item index");
      return;
    }

    const newSplitIndex = getUniqueIndex();
    const newRowHtml = createSplitRowHtml(itemIndex, newSplitIndex, '');

    const frag = document.createElement('div');
    frag.innerHTML = newRowHtml.trim();
    const newRow = frag.firstElementChild;

    splitsContainer.appendChild(newRow);
    updateParticipantDropdowns();
  };

  const onContainerClick = (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;

    if (btn.classList.contains('add-split')) {
      e.preventDefault();
      const card = btn.closest('.item-card');
      if (card) addSplit(card);
    }

    if (btn.classList.contains('remove-item')) {
      e.preventDefault();
      const card = btn.closest('.item-card');
      if (!card) return;
      const idField = card.querySelector('input[name*="[id]"]');
      if (idField && idField.value) {
        const destroyInput = document.createElement('input');
        destroyInput.type = 'hidden';
        destroyInput.name = idField.name.replace('[id]', '[_destroy]');
        destroyInput.value = '1';
        card.appendChild(destroyInput);
        card.style.display = 'none';
      } else {
        card.remove();
      }
    }

    if (btn.classList.contains('remove-split')) {
      e.preventDefault();
      const splitRow = btn.closest('.split-row');
      if (!splitRow) return;

      const idInput = splitRow.querySelector('input[name*="[id]"]');
      if (idInput && idInput.value) {
        const destroyInput = splitRow.querySelector('.destroy-flag') || document.createElement('input');
        if (!destroyInput.classList.contains('destroy-flag')) {
          destroyInput.type = 'hidden';
          destroyInput.name = idInput.name.replace('[id]', '[_destroy]');
          splitRow.appendChild(destroyInput);
        }
        destroyInput.value = '1';
        splitRow.style.display = 'none';
      } else {
        splitRow.remove();
      }
    }

    if (btn.classList.contains('equal-split')) {
      e.preventDefault();
      const card = btn.closest('.item-card');
      if (!card) return;

      const amountInput = card.querySelector('.item-amount');
      const total = parseFloat(amountInput.value || '0');
      let rows = Array.from(card.querySelectorAll('.split-row')).filter(row => row.offsetParent !== null);
      const participants = getCheckedParticipants();
      const n = participants.length;

      if (n === 0) {
        alert('Please select participants from the list first.');
        return;
      }
      if (total === 0 || isNaN(total)) {
        alert('Please enter an item amount first.');
        return;
      }

      while (rows.length < n) {
        addSplit(card);
        rows = Array.from(card.querySelectorAll('.split-row')).filter(row => row.offsetParent !== null);
      }

      const share = Math.round((total / n) * 100) / 100;
      let assigned = 0;
      participants.forEach((participant, idx) => {
        const row = rows[idx];
        const userSelect = row.querySelector('.split-user');
        const amtInput = row.querySelector('.split-amount');
        if (userSelect) userSelect.value = participant.id;
        let amt = (idx === n - 1) ? (total - assigned).toFixed(2) : share.toFixed(2);
        if (idx !== n - 1) assigned += share;
        if (amtInput) amtInput.value = amt;
      });

      for (let i = n; i < rows.length; i++) {
        const row = rows[i];
        const idInput = row.querySelector('input[name*="[id]"]');
        if (idInput && idInput.value) {
          const destroyInput = row.querySelector('.destroy-flag') || document.createElement('input');
          if (!destroyInput.parentNode) {
            destroyInput.type = 'hidden';
            destroyInput.name = idInput.name.replace('[id]', '[_destroy]');
            row.appendChild(destroyInput);
          }
          destroyInput.value = '1';
          row.style.display = 'none';
        } else {
          row.remove();
        }
      }
    }
  };

  const showError = (e, msg) => {
    e.preventDefault();
    e.stopImmediatePropagation();

    const submitBtns = document.querySelectorAll('input[type="submit"], button[type="submit"]');
    submitBtns.forEach(btn => {
      setTimeout(() => { btn.disabled = false; }, 50);
    });

    const errorContainer = document.getElementById('frontend-error-container');
    const errorMessage = document.getElementById('frontend-error-message');

    if (errorContainer && errorMessage) {
      errorMessage.textContent = msg;
      errorContainer.classList.remove('d-none');
      window.scrollTo({ top: 0, behavior: 'smooth' });
    } else {
      alert(msg);
    }
  };

  const validateTotal = (e) => {
    const errorContainer = document.getElementById('frontend-error-container');
    if (errorContainer) errorContainer.classList.add('d-none');

    // 1. Check at least one item (that is not hidden/deleted)
    const items = Array.from(document.querySelectorAll('.item-card')).filter(card => card.style.display !== 'none');
    if (items.length === 0) {
      showError(e, "Please add at least one expense item.");
      return;
    }

    // 2. Check individual item/split sums
    for (let i = 0; i < items.length; i++) {
      const item = items[i];
      const nameInput = item.querySelector('input[name*="[name]"]');
      const itemName = nameInput ? nameInput.value : `Item ${i + 1}`;

      const itemAmountInput = item.querySelector('.item-amount');
      const itemAmount = parseFloat(itemAmountInput.value || 0);

      const splitRows = Array.from(item.querySelectorAll('.split-row')).filter(row => row.style.display !== 'none');
      let splitSum = 0;

      for (const split of splitRows) {
        const amtInput = split.querySelector('.split-amount');
        splitSum += parseFloat(amtInput.value || 0);
        // Rely on HTML 'required' attribute for empty field validation during submission
      }

      if (Math.abs(itemAmount - splitSum) > 0.05) {
        showError(e, `Split amounts for "${itemName}" (${splitSum.toFixed(2)}) do not match the item amount (${itemAmount}).`);
        return;
      }
    }

    // 3. Check Total Expense Amount
    const totalInput = document.getElementById('expense_transaction_amount');
    const totalAmount = parseFloat(totalInput.value || '0');

    const itemAmounts = items.map(input => {
      const amt = input.querySelector('.item-amount');
      return parseFloat(amt.value || '0');
    });

    const sumItems = itemAmounts.reduce((a, b) => a + b, 0);

    if (Math.abs(totalAmount - sumItems) > 0.05) {
      showError(e, `Total Expense Amount (${totalAmount}) must equal the sum of Items (${sumItems.toFixed(2)}).`);
    }
  };

  const participantCheckboxes = document.querySelectorAll('.participant-toggle');
  participantCheckboxes.forEach(checkbox => {
    checkbox.addEventListener('change', updateParticipantDropdowns);
  });

  const btnAddItem = document.getElementById('add-item');
  const btnAddTax = document.getElementById('add-tax');
  const btnAddTip = document.getElementById('add-tip');

  if (btnAddItem) btnAddItem.addEventListener('click', (e) => { e.preventDefault(); addItem('Item'); });
  if (btnAddTax) btnAddTax.addEventListener('click', (e) => { e.preventDefault(); addItem('Tax'); });
  if (btnAddTip) btnAddTip.addEventListener('click', (e) => { e.preventDefault(); addItem('Tip'); });

  if (container) container.addEventListener('click', onContainerClick);
  if (expenseForm) expenseForm.addEventListener('submit', validateTotal);

  updateParticipantDropdowns();
});
