(function () {
    const resourceName = 'az-jobcenter'; // must match your resource folder name

    const root = document.getElementById('job-center');
    const listEl = document.getElementById('job-list');
    const detailsEl = document.getElementById('job-details');
    const playerNameEl = document.getElementById('player-name');
    const playerJobEl = document.getElementById('player-job');
    const searchEl = document.getElementById('job-search');
    const categoryEl = document.getElementById('job-category-filter');
    const btnApply = document.getElementById('btn-apply');
    const btnClose = document.getElementById('btn-close');
    const toastEl = document.getElementById('jc-toast');
    const toastIconEl = document.getElementById('jc-toast-icon');
    const toastTextEl = document.getElementById('jc-toast-text');

    let jobs = [];
    let filteredJobs = [];
    let selectedJobId = null;
    let toastTimeout = null;

    function showRoot() {
        root.classList.remove('hidden');
    }

    function hideRoot() {
        root.classList.add('hidden');
        selectedJobId = null;
        listEl.innerHTML = '';
        detailsEl.innerHTML = `
            <div class="job-details-empty">
                <h2>Select a job on the left</h2>
                <p>Browse through available careers in Los Santos and pick the one that fits your style.</p>
                <div class="job-details-hint">
                    <i class="fa-solid fa-mouse-pointer"></i>
                    Click on any job card to see its details.
                </div>
            </div>
        `;
    }

    function setPlayerInfo(player) {
        if (!player) return;
        playerNameEl.textContent = player.name || 'Citizen';
        playerJobEl.textContent = player.jobLabel || 'Unemployed';
    }

    function renderCategories() {
        const cats = new Set();
        jobs.forEach(j => {
            if (j.category) cats.add(j.category);
        });

        categoryEl.innerHTML = '<option value="">All categories</option>';
        Array.from(cats).sort().forEach(cat => {
            const opt = document.createElement('option');
            opt.value = cat;
            opt.textContent = cat;
            categoryEl.appendChild(opt);
        });
    }

    function applyFilters() {
        const term = (searchEl.value || '').toLowerCase();
        const cat = categoryEl.value || '';

        filteredJobs = jobs.filter(j => {
            const matchesCat = !cat || (j.category === cat);
            const matchesTerm =
                !term ||
                (j.label && j.label.toLowerCase().includes(term)) ||
                (j.description && j.description.toLowerCase().includes(term));
            return matchesCat && matchesTerm;
        });

        renderJobList();
    }

    function renderJobList() {
        listEl.innerHTML = '';

        if (!filteredJobs.length) {
            const empty = document.createElement('div');
            empty.className = 'job-details-empty';
            empty.innerHTML = `
                <h2>No jobs found</h2>
                <p>Try changing the search or selecting a different category.</p>
            `;
            listEl.appendChild(empty);
            return;
        }

        filteredJobs.forEach(job => {
            const card = document.createElement('div');
            card.className = 'jc-job-card';
            card.dataset.jobId = job.id;

            if (selectedJobId === job.id) {
                card.classList.add('selected');
            }

            const iconBgColor = job.color || '#00b4ff';
            const salary = typeof job.salary === 'number' ? job.salary : 0;
            const shortDesc = (job.description || '').length > 80
                ? job.description.slice(0, 80) + '...'
                : (job.description || '');

            card.innerHTML = `
                <div class="jc-job-icon" style="background: radial-gradient(circle at 30% 0%, rgba(255,255,255,0.35), transparent 50%), linear-gradient(145deg, ${iconBgColor}, #050b13);">
                    <i class="fa-solid ${job.icon || 'fa-briefcase'}"></i>
                </div>
                <div class="jc-job-main">
                    <div class="jc-job-title">${job.label || 'Job'}</div>
                    <div class="jc-job-category">${job.category || 'General'}</div>
                </div>
                <div class="jc-job-salary">
                    Salary<br />
                    <span>$${salary}</span>
                </div>
                <div class="jc-job-tagline">
                    ${shortDesc}
                </div>
            `;

            card.addEventListener('click', () => {
                selectJob(job.id);
            });

            listEl.appendChild(card);
        });
    }

    function getJobById(id) {
        return jobs.find(j => j.id === id);
    }

    function selectJob(jobId) {
        selectedJobId = jobId;

        document.querySelectorAll('.jc-job-card').forEach(el => {
            el.classList.toggle('selected', el.dataset.jobId === jobId);
        });

        const job = getJobById(jobId);
        if (!job) {
            detailsEl.innerHTML = `
                <div class="job-details-empty">
                    <h2>Job not found</h2>
                    <p>Please select another job from the list.</p>
                </div>
            `;
            return;
        }

        const salary = typeof job.salary === 'number' ? job.salary : 0;
        const duties = Array.isArray(job.duties) ? job.duties : [];
        const color = job.color || '#00b4ff';

        detailsEl.innerHTML = `
            <div class="jc-details-header">
                <div class="jc-details-title">
                    <span>Position</span>
                    <span>${job.label || 'Job'}</span>
                </div>
                <div class="jc-details-badge" style="border-color: ${color};">
                    ${job.category || 'General'}
                </div>
            </div>
            <div class="jc-details-body">
                <div class="jc-details-summary">
                    <div class="jc-details-summary-block">
                        <div class="jc-details-summary-label">Base Salary</div>
                        <div class="jc-details-summary-value" style="color:#9eff7f;">$${salary}</div>
                    </div>
                    <div class="jc-details-summary-block">
                        <div class="jc-details-summary-label">Job ID</div>
                        <div class="jc-details-summary-value" style="color:${color};">${job.id}</div>
                    </div>
                </div>
                <div class="jc-details-description">
                    ${job.description || 'No description provided for this job.'}
                </div>
                <div>
                    <div class="jc-details-duties-title">Primary Duties</div>
                    <ul class="jc-details-duties-list">
                        ${duties.length
                            ? duties.map(d => `
                                <li>
                                    <i class="fa-solid fa-circle-small"></i>
                                    <span>${d}</span>
                                </li>
                            `).join('')
                            : `
                                <li>
                                    <i class="fa-solid fa-circle-small"></i>
                                    <span>No specific duties listed. Ask your supervisor in roleplay!</span>
                                </li>
                            `
                        }
                    </ul>
                </div>
            </div>
        `;
    }

    function showToast(message, type) {
        type = type || 'info';

        toastEl.classList.remove('hidden', 'success', 'error', 'info');
        toastEl.classList.add(type);
        toastEl.style.animation = 'jc-toast-in 0.22s ease-out forwards';

        let iconHtml = '<i class="fa-solid fa-circle-info"></i>';
        if (type === 'success') {
            iconHtml = '<i class="fa-solid fa-check"></i>';
        } else if (type === 'error') {
            iconHtml = '<i class="fa-solid fa-triangle-exclamation"></i>';
        }

        toastIconEl.innerHTML = iconHtml;
        toastTextEl.textContent = message || 'Notification';

        if (toastTimeout) {
            clearTimeout(toastTimeout);
        }

        toastTimeout = setTimeout(() => {
            toastEl.style.animation = 'jc-toast-out 0.2s ease-in forwards';
            setTimeout(() => {
                toastEl.classList.add('hidden');
            }, 210);
        }, 2600);
    }

    function nuiPost(name, data) {
        try {
            fetch(`https://${resourceName}/${name}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                },
                body: JSON.stringify(data || {}),
            }).catch(() => {});
        } catch (e) {
            // ignore
        }
    }

    window.addEventListener('message', (event) => {
        const data = event.data || {};
        const action = data.action;

        if (action === 'open') {
            jobs = Array.isArray(data.jobs) ? data.jobs : [];
            setPlayerInfo(data.player);
            renderCategories();
            searchEl.value = '';
            categoryEl.value = '';
            applyFilters();
            selectedJobId = data.player && data.player.jobId ? data.player.jobId : null;
            if (selectedJobId) {
                selectJob(selectedJobId);
            } else if (filteredJobs.length) {
                selectJob(filteredJobs[0].id);
            }
            showRoot();
        } else if (action === 'close') {
            hideRoot();
        } else if (action === 'updateJob') {
            if (data.jobLabel) {
                playerJobEl.textContent = data.jobLabel;
            }
            if (data.jobId) {
                selectedJobId = data.jobId;
                selectJob(data.jobId);
            }
        } else if (action === 'notify') {
            showToast(data.message, data.ntype);
        }
    });

    btnApply.addEventListener('click', () => {
        if (!selectedJobId) {
            showToast('Select a job first.', 'error');
            return;
        }
        nuiPost('applyJob', { jobId: selectedJobId });
    });

    btnClose.addEventListener('click', () => {
        nuiPost('close', {});
    });

    searchEl.addEventListener('input', applyFilters);
    categoryEl.addEventListener('change', applyFilters);

    window.addEventListener('keydown', (ev) => {
        if (ev.key === 'Escape') {
            nuiPost('close', {});
        }
    });
})();
