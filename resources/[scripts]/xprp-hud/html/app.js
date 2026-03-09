'use strict';

const hud       = document.getElementById('hud');
const healthBar = document.getElementById('health-bar');
const healthVal = document.getElementById('health-val');
const armourBar = document.getElementById('armour-bar');
const armourVal = document.getElementById('armour-val');
const cashVal   = document.getElementById('cash-val');
const bankVal   = document.getElementById('bank-val');
const jobVal    = document.getElementById('job-val');

function formatMoney(amount) {
    return '$' + Number(amount).toLocaleString('en-US');
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'show') {
        hud.classList.remove('hidden');
    }

    if (data.action === 'hide') {
        hud.classList.add('hidden');
    }

    if (data.action === 'update') {
        const hp = Math.min(100, Math.max(0, data.health ?? 100));
        const ar = Math.min(100, Math.max(0, data.armour ?? 0));

        healthBar.style.width = hp + '%';
        healthVal.textContent = hp;
        armourBar.style.width = ar + '%';
        armourVal.textContent = ar;

        cashVal.textContent = formatMoney(data.cash ?? 0);
        bankVal.textContent = formatMoney(data.bank ?? 0);
        jobVal.textContent  = (data.job ?? 'unemployed').replace(/_/g, ' ');
    }
});
