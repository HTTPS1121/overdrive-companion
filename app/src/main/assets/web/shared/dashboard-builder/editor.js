/* Dashboard builder. The editor keeps authoring data separate from vehicle settings. */
(function () {
    'use strict';
    const D = window.DashboardDesign, $ = id => document.getElementById('db-' + id);
    const tr = (key, vars) => BYD.i18n.t('dashboardBuilder.' + key, vars);
    const local = '/api/custom-layouts/dashboards', community = '/api/community/dashboards/';
    const copy = o => JSON.parse(JSON.stringify(o));
    const state = { page: 'design', recipe: D.initial('cobalt-pair'), name: '', id: null, revision: null, baseline: '', selected: -1, mode:'widgets', camera:'right', busy: false,
        signalLabels: {}, signalCatalog: [], units: {distance:'km',tyre:'psi'}, currency:'INR',
        library: [], activeId: null, publicItems: [], next: null, listRequest: 0, publicRequest: 0, panel: 480, theme: 'dark', scenario: 'drive' };
    let modalAction = null, returnFocus = null, drag = null, filterTimer = null, drawRequest = 0;
    let documentGeneration = 0, navigationGeneration = 0, publishRequest = 0;
    let past = [], future = [], lastEdit = '';
    function text(tag, value, cls) {
        const e = document.createElement(tag);
        if (cls)
            e.className = cls;
        if (value != null)
            e.textContent = value;
        return e;
    }
    function button(name, action) {
        const b = text('button', name);
        b.type = 'button';
        b.onclick = action;
        return b;
    }
    function options(select, choices, value) {
        select.textContent = '';
        choices.forEach(k => select.add(new Option(k[1], k[0])));
        if (value != null)
            select.value = value;
    }
    function entries(o) { return Object.keys(o).map(k => [k, o[k]]); }
    function store(k, v, tabOnly) {
        try {
            const storage = tabOnly ? sessionStorage : localStorage;
            if (v == null)
                storage.removeItem(k);
            else
                storage.setItem(k, JSON.stringify(v));
        }
        catch (ignored) { }
    }
    function read(k, tabOnly) { try {
        return JSON.parse((tabOnly ? sessionStorage : localStorage).getItem(k));
    }
    catch (ignored) {
        return null;
    } }
    function tell(message, error) {
        $('message').textContent = message || '';
        $('message').dataset.error = error ? 'true' : 'false';
    }
    function signature() { return JSON.stringify([state.name, state.recipe]); }
    function dirty() { return signature() !== state.baseline; }
    function remember() {
        const draft = { name: state.name, recipe: state.recipe, id: state.id, revision: state.revision, baseline: state.baseline };
        store('od.dashboard.work.v1', draft, true);
        store('od.dashboard.work.v1', draft);
    }
    function stamp(clean) {
        if (clean)
            state.baseline = signature();
        $('save').disabled = state.busy || !state.name.trim() || !!(state.id && !dirty());
        $('copy').hidden = !state.id;
        remember();
    }
    function mark() {
        const now = signature();
        if (lastEdit && lastEdit !== now) {
            past.push(lastEdit);
            if (past.length > 70) past.shift();
            future = [];
        }
        lastEdit = now;
        historyButtons();
        stamp(false);
        tell(tr('unsaved'));
    }
    function historyButtons() {
        $('undo').disabled = !past.length;
        $('redo').disabled = !future.length;
    }
    function moveHistory(backward) {
        const from = backward ? past : future, to = backward ? future : past;
        if (!from.length) return;
        to.push(signature());
        lastEdit = from.pop();
        const restored = JSON.parse(lastEdit);
        state.name = restored[0]; state.recipe = restored[1];
        editor(); historyButtons(); tell(dirty() ? tr('unsaved') : '');
    }
    function lock(value) {
        state.busy = value;
        const main = $('design');
        if (value)
            main.setAttribute('aria-busy', 'true');
        else
            main.removeAttribute('aria-busy');
        $('new').disabled = value;
        $('copy').disabled = value;
        stamp(false);
    }
    async function api(method, path, payload) {
        const opts = { method: method, cache: 'no-store', headers: { Accept: 'application/json' } };
        if (payload !== undefined) {
            opts.headers['Content-Type'] = 'application/json';
            opts.body = JSON.stringify(payload);
        }
        let response;
        try {
            response = await (typeof BYDAuth !== 'undefined' ? BYDAuth.fetch(path, opts) : fetch(path, opts));
        }
        catch (e) {
            throw new Error(tr('offline'));
        }
        let json;
        try {
            json = await response.json();
        }
        catch (e) {
            json = {};
        }
        if (!response.ok || json.success === false) {
            const err = new Error(json.error || json.message || (tr('requestStatus', {status: response.status})));
            err.status = response.status;
            throw err;
        }
        return json;
    }
    async function run(action) {
        if (state.busy)
            return;
        lock(true);
        try {
            await action();
        }
        catch (e) {
            tell(e.message || tr('requestError'), true);
        }
        finally {
            lock(false);
        }
    }
    function stageOptions(width) {
        return { panel:state.panel, theme:state.theme, scenario:state.scenario, width:width || 1200,
            labels:state.signalLabels, units:state.units, currency:state.currency };
    }
    function draw() {
        const parked = state.scenario === 'idle';
        document.querySelector('#db-stage .db-rail-top strong').firstChild.nodeValue = parked ? 'P ' : 'D ';
        document.querySelector('#db-stage .db-rail-bottom > span').firstChild.nodeValue = parked ? '0 ' : '34 ';
        document.querySelector('.db-rail-bottom b').textContent = D.formatReading('range_km',371,{units:state.units});
        D.preview($('canvas'), state.recipe, stageOptions());
    }
    function redrawCards() {
        document.querySelectorAll('#db canvas[data-recipe-preview]').forEach(c =>
            D.preview(c, c._recipe, cardOptions(c.dataset.recipePreview === 'large' ? 1440 : 600)));
    }
    function cardOptions(width) { return Object.assign(stageOptions(width), {scenario:'drive'}); }
    function presetImage(img, id) {
        const day = state.theme === 'light';
        const src = '../shared/dashboard-builder/images/previews/' + (day ? 'day/' : 'night/') + id + '.webp';
        if (img.getAttribute('src') !== src) {
            img.width = 720; img.height = day ? 270 : 180; img.src = src;
        }
    }
    function recipePreview(recipe, name, large) {
        const canvas = document.createElement('canvas');
        canvas.dataset.recipePreview = large ? 'large' : 'card';
        canvas.setAttribute('aria-label', tr('namedPreview', {name}));
        canvas._recipe = recipe;
        D.preview(canvas,recipe,cardOptions(large ? 1440 : 600));
        return canvas;
    }
    window.addEventListener('dashboard-art-loaded', () => {
        if (drawRequest)
            return;
        drawRequest = requestAnimationFrame(() => {
            drawRequest = 0;
            draw();
            redrawCards();
        });
    });
    function widget() { return state.recipe.widgets[state.selected]; }
    function speedIndex() { return state.recipe.widgets.findIndex(w => w.type === 'speed'); }
    function signalLabel(key) { return state.signalLabels[key] || D.signals[key].label; }
    function widgetName(w) { return w.signal ? signalLabel(w.signal) + ' · ' + D.faces[w.type] : D.kinds[w.type]; }
    function cameraMode() { return state.mode === 'cameras'; }
    function activeBox() { return cameraMode() ? D.editableCamera(state.recipe,state.panel,state.camera) : widget(); }
    function assignBox(box) {
        if (cameraMode()) {
            D.upgrade(state.recipe);
            if (!state.recipe.cameras) state.recipe.cameras = {};
            state.recipe.cameras[state.camera] = copy(box);
        } else Object.assign(widget(),box);
    }
    function chooseCamera(side) {
        state.camera=side;
        state.scenario=side;
        $('scenario').value=side;
    }
    function values() {
        const w = activeBox();
        if (w)
            ['x', 'y', 'w', 'h'].forEach(k => $(k).value = w[k] / 10);
    }
    function position(e, w) {
        ['left', 'top', 'width', 'height'].forEach((k, i) => { e.style[k] = (w[['x', 'y', 'w', 'h'][i]] / 10) + '%'; });
    }
    function handles() {
        const box = $('handles');
        const area = cameraMode() ? {x:0,y:0,w:1,h:1} : D.area(state.recipe);
        box.style.left = area.x * 100 + '%'; box.style.top = area.y * 100 + '%';
        box.style.width = area.w * 100 + '%'; box.style.height = area.h * 100 + '%';
        box.textContent = '';
        const entries = cameraMode() ? ['left','right'].map(side => {
            const [x,y,w,h,round]=D.cameraFrame(state.recipe,state.panel,side);
            return { key:side, name:side === 'left' ? tr('leftCamera') : tr('rightCamera'), round,
                box:{x:x/1.92,y:y*1000/state.panel,w:w/1.92,h:h*1000/state.panel} };
        }) : D.stack(state.recipe.widgets).map(w => ({key:String(state.recipe.widgets.indexOf(w)),name:widgetName(w),box:w}));
        entries.forEach(item => {
            const b=button('',()=>pick(item.key));
            b.className = 'db-handle';
            b.dataset.key=item.key;
            if (cameraMode()) {
                b.dataset.side=item.key;
                b.dataset.round=String(item.round);
                b.classList.add('db-camera-handle');
                b.appendChild(text('span',item.name,'db-camera-name'));
            } else b.dataset.kind=item.box.type;
            b.setAttribute('aria-label',tr('selectInstrument', {name: item.name}));
            b.setAttribute('aria-pressed',String(item.key===String(cameraMode()?state.camera:state.selected)));
            const corner = text('span', null, 'db-resize');
            corner.setAttribute('aria-hidden', 'true');
            b.appendChild(corner);
            position(b,item.box);
            box.appendChild(b);
        });
    }
    function inspector() {
        const w = widget();
        const ordered = D.stack(state.recipe.widgets);
        const cameras=cameraMode();
        $('inspector-title').textContent=cameras ? tr('blindSpotViews') : tr('instruments');
        $('stage').dataset.mode=state.mode;
        $('stage-help').textContent=cameras ? tr('cameraHelp') : tr('widgetGeometryHelp');
        $('edit-mode').querySelectorAll('button').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.mode===state.mode)));
        $('camera-tools').hidden=!cameras;
        $('add-menu').hidden=cameras; $('layers').hidden=cameras; $('layer-foot').hidden=cameras;
        $('binding').hidden=cameras || !w || !w.signal;
        $('convert').hidden=cameras || !w || !['power','range','speed'].includes(w.type);
        if (!$('convert').hidden) $('convert').textContent=w.type==='speed' ? tr('addReading') : tr('changeReading');
        $('expand').hidden=cameras || state.recipe.space === 'panel';
        if (cameras) {
            $('camera-tools').querySelectorAll('[data-side]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.side===state.camera)));
            $('camera-reset').disabled=!(state.recipe.cameras && state.recipe.cameras[state.camera]);
            $('w').min=15; $('h').min=22; $('w').max=50; $('h').max=70;
            values();
            return;
        }
        options($('selected'),state.recipe.widgets.map((w,i)=>[String(i),widgetName(w)]),String(state.selected));
        if (w && w.signal) {
            $('signal').value=w.signal;
            $('face').value=w.type;
        }
        $('remove').disabled = !w || w.type === 'speed';
        const depth = ordered.indexOf(w);
        $('back').disabled = depth <= 0 || w.type === 'speed';
        $('front').disabled = depth >= ordered.length - 2 || w.type === 'speed';
        $('depth').textContent = w.type==='speed' ? tr('speedForeground') : tr('layerIndex', {layer: depth + 1, total: ordered.length});
        const min = D.minimum(state.recipe,w.type);
        $('w').max=100; $('h').max=100;
        $('w').min = min[0] / 10; $('h').min = min[1] / 10;
        const layers = $('layers'); layers.textContent = '';
        ordered.slice().reverse().forEach(layer => {
            const i=state.recipe.widgets.indexOf(layer);
            const b = button(widgetName(layer), () => pick(String(i)));
            b.setAttribute('aria-pressed', String(layer===w));
            layers.appendChild(b);
        });
        values();
    }
    function shiftLayer(step) {
        if (cameraMode() || widget().type === 'speed') return;
        const current=widget(),ordered = D.stack(state.recipe.widgets), i = ordered.indexOf(current), to = i + step;
        if (i < 0 || to < 0 || to >= ordered.length - 1) return;
        [ordered[i], ordered[to]] = [ordered[to], ordered[i]];
        state.recipe.widgets = ordered; state.selected=to; editor(); mark();
    }
    function pick(key) {
        if (cameraMode()) chooseCamera(key); else state.selected=Number(key);
        inspector();
        Array.from($('handles').children).forEach(b => b.setAttribute('aria-pressed', String(b.dataset.key===String(key))));
        if (cameraMode()) draw();
    }
    function editor() {
        $('name').value = state.name;
        $('template').value = state.recipe.template;
        $('accent').value = state.recipe.accent;
        $('background').value=state.recipe.background || 'template';
        $('background-sample').dataset.background=$('background').value;
        $('background-sample').dataset.theme=state.theme;
        $('templates').querySelectorAll('button').forEach(b => {
            b.setAttribute('aria-pressed', String(b.dataset.template === state.recipe.template));
            presetImage(b.querySelector('img'), b.dataset.template);
        });
        $('swatches').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.accent === state.recipe.accent)));
        $('light-choices').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.value === state.theme)));
        const missing = state.recipe.widgets.length >= 24 ? [] : entries(D.faces).concat(entries(D.kinds).filter(row => !state.recipe.widgets.some(w => w.type === row[0])));
        options($('add-kind'), missing);
        $('add-kind').disabled = !missing.length;
        $('add').disabled = !missing.length;
        $('add-menu').disabled = !missing.length;
        const list = $('add-list'); list.textContent = ''; list.hidden = true; $('add-menu').setAttribute('aria-expanded','false');
        for (const [title,rows] of [[tr('customReadings'),missing.filter(([type])=>D.faces[type])],[tr('dashboardInstruments'),missing.filter(([type])=>D.kinds[type])]]) {
            if (!rows.length) continue;
            const group = text('div',null,'db-add-group');
            group.appendChild(text('strong',title));
            rows.forEach(row => group.appendChild(button(row[1], () => { $('add-kind').value = row[0]; $('add').click(); })));
            list.appendChild(group);
        }
        if (!widget())
            state.selected=speedIndex();
        inspector();
        handles();
        $('stage').dataset.height = String(state.panel);
        $('stage').dataset.theme = state.theme;
        draw();
        stamp(false);
    }
    function enter(name, recipe, id, revision) {
        documentGeneration++;
        drag = null;
        state.recipe = copy(recipe);
        state.id = id || null;
        state.revision = Number.isInteger(revision) ? revision : null;
        state.name = name;
        state.selected=speedIndex();
        if (cameraMode()) { state.mode='widgets'; state.scenario='drive'; $('scenario').value='drive'; }
        state.baseline = signature();
        past = []; future = []; lastEdit = signature(); historyButtons();
        show('design');
        editor();
    }
    function changeDoc(action) {
        if (dirty()) {
            modal(tr('replaceEdits'), [], tr('replace'), action, tr('keepDraft'));
        }
        else
            action();
    }
    function show(page) {
        if (state.page !== page) {
            navigationGeneration++;
            publishRequest++;
        }
        state.page = page;
        ['design', 'library', 'community'].forEach(k => $(k).hidden = k !== page);
        document.querySelectorAll('#db .db-nav button').forEach(b => {
            if (b.dataset.page === page)
                b.setAttribute('aria-current', 'page');
            else
                b.removeAttribute('aria-current');
        });
        if (location.hash !== '#' + page)
            history.replaceState(null, '', location.pathname + location.search + '#' + page);
        if (page === 'library')
            loadLibrary();
        else if (page === 'community')
            loadCommunity(true);
    }
    function modal(title, fields, confirm, act, desc) {
        publishRequest++;
        const m = $('modal'), body = $('modal-body');
        body.textContent = '';
        $('modal-title').textContent = title;
        if (desc)
            body.appendChild(text('p', desc, 'db-copy'));
        const inputs = {};
        fields.forEach(f => {
            const l = text('label', f.label);
            let e;
            if (f.options) {
                e = document.createElement('select');
                options(e, f.options, f.value);
            }
            else {
                e = document.createElement(f.multiline ? 'textarea' : 'input');
                e.value = f.value || '';
                e.maxLength = f.max || 100;
                if (f.required)
                    e.required = true;
            }
            inputs[f.key] = e;
            l.appendChild(e);
            body.appendChild(l);
            if (f.key === 'template') {
                const image = document.createElement('img');
                image.className = 'db-preset-frame';
                function update() {
                    presetImage(image,e.value);
                    image.alt = tr('namedPreview', {name:D.templates[e.value][0]});
                }
                update(); e.addEventListener('change',update); body.appendChild(image);
            }
        });
        returnFocus = document.activeElement;
        modalAction = () => {
            const values = {};
            for (const k of Object.keys(inputs)) {
                const e = inputs[k];
                if (e.required && !e.value.trim()) {
                    e.focus();
                    return;
                }
                values[k] = e.value.trim();
            }
            closeModal();
            act(values);
        };
        $('confirm').textContent = confirm;
        m.hidden = false;
        (Object.values(inputs)[0] || $('cancel')).focus();
    }
    function closeModal() {
        const previous = returnFocus;
        $('modal').hidden = true;
        $('modal').classList.remove('db-preview-dialog');
        $('cancel').hidden = false;
        modalAction = null;
        returnFocus = null;
        if (previous && previous.isConnected)
            previous.focus();
    }
    function identify(data) {
        const item = data && data.item;
        if (!item || typeof item.id !== 'string' || !D.valid(item.recipe))
            throw new Error(tr('badDashboard'));
        return item;
    }
    async function save(asCopy) {
        const name = state.name.trim();
        if (!name || !D.valid(state.recipe))
            throw new Error(tr('invalidLayout'));
        const editing = !asCopy && !!state.id, sourceId = state.id, body = { name: name, recipe: copy(state.recipe) };
        const generation = documentGeneration, before = signature();
        if (editing)
            body.revision = state.revision;
        let data;
        try {
            data = await api(editing ? 'PUT' : 'POST', editing ? local + '/' + encodeURIComponent(sourceId) : local, body);
        }
        catch (e) {
            if (generation !== documentGeneration)
                return;
            if (e.status === 409 && editing)
                throw new Error(tr('revisionConflict'));
            throw e;
        }
        const item = identify(data);
        if (generation === documentGeneration) {
            const editedWhileSaving = before !== signature();
            state.id = item.id;
            state.revision = item.revision;
            state.baseline = JSON.stringify([item.name, editedWhileSaving ? body.recipe : item.recipe]);
            if (!editedWhileSaving) {
                state.name = item.name;
                state.recipe = copy(item.recipe);
                editor();
            }
            stamp(false);
            tell(editedWhileSaving ? tr('earlierSaved') : tr('saved'));
        }
        if (state.page === 'library')
            await loadLibrary();
    }
    function geometryEdit() {
        const w = activeBox();
        if (!w)
            return;
        const candidate = Object.assign({}, w);
        for (const k of ['x', 'y', 'w', 'h']) {
            const e = $(k);
            if (!e.value.trim() || !Number.isFinite(e.valueAsNumber)) {
                values();
                tell(tr('percentageRequired'), true);
                return;
            }
            candidate[k] = Math.round(e.valueAsNumber * 10);
        }
        if (!canPlace(candidate)) {
            values();
            tell(cameraMode() ? tr('cameraBounds') : tr('instrumentBounds'), true);
            return;
        }
        assignBox(candidate);
        inspector();
        handles();
        values();
        draw();
        mark();
    }
    function canPlace(candidate) { return cameraMode() ? D.cameraGeometry(candidate) : D.geometry(candidate,state.recipe); }
    function bindHandles() {
        const area = $('handles');
        area.addEventListener('pointerdown', e => {
            const b = e.target.closest('.db-handle');
            if (!b || drag || e.button !== 0)
                return;
            pick(b.dataset.key);
            const w=activeBox();
            b.focus();
            const r = area.getBoundingClientRect();
            if (!r.width || !r.height)
                return;
            drag = { id:e.pointerId,b,original:copy(w),recipeBefore:copy(state.recipe),startX:e.clientX,startY:e.clientY,rect:r,resize:e.target.classList.contains('db-resize') };
            if (b.setPointerCapture)
                b.setPointerCapture(e.pointerId);
            e.preventDefault();
        });
        area.addEventListener('pointermove', e => {
            if (!drag || drag.id !== e.pointerId)
                return;
            const d = drag, a = d.original, n = copy(a), dx = Math.round((e.clientX - d.startX) * 1000 / d.rect.width), dy = Math.round((e.clientY - d.startY) * 1000 / d.rect.height);
            if (d.resize) {
                const min=cameraMode() ? [150,220] : D.minimum(state.recipe,n.type);
                n.w = Math.max(min[0], Math.min(1000-a.x,cameraMode()?500:1000,a.w+dx));
                n.h = Math.max(min[1], Math.min(1000-a.y,cameraMode()?700:1000,a.h+dy));
            }
            else {
                n.x = Math.max(0, Math.min(1000 - a.w, a.x + dx));
                n.y = Math.max(0, Math.min(1000 - a.h, a.y + dy));
            }
            const ok=canPlace(n);
            d.b.dataset.invalid = String(!ok);
            if (ok) {
                if (cameraMode() && !dx && !dy && !d.changed) return;
                d.changed=true;
                assignBox(n);
                if (cameraMode()) d.b.dataset.round='false';
                position(d.b,n);
                values();
                draw();
            }
        });
        function finish(e, cancel) {
            if (!drag || drag.id !== e.pointerId)
                return;
            const d = drag;
            drag = null;
            if (cancel) state.recipe=d.recipeBefore;
            d.b.dataset.invalid = 'false';
            if (d.changed) {
                inspector();
                if (cancel) handles();
                draw();
                if (!cancel && JSON.stringify(d.recipeBefore)!==JSON.stringify(state.recipe)) mark();
            }
        }
        area.addEventListener('pointerup', e => finish(e, false));
        area.addEventListener('pointercancel', e => finish(e, true));
        area.addEventListener('lostpointercapture', e => finish(e, false));
        area.addEventListener('keydown', e => {
            const b = e.target.closest('.db-handle');
            if (!b || !/^Arrow(Up|Down|Left|Right)$/.test(e.key))
                return;
            e.preventDefault();
            pick(b.dataset.key);
            const n=copy(activeBox());
            const prop = e.key === 'ArrowLeft' || e.key === 'ArrowRight' ? 'x' : 'y';
            n[prop] += (e.key === 'ArrowLeft' || e.key === 'ArrowUp' ? -1 : 1) * (e.shiftKey ? 20 : 5);
            if (canPlace(n)) {
                assignBox(n);
                if (cameraMode()) b.dataset.round='false';
                position(b,n);
                inspector();
                draw();
                mark();
            }
        });
    }
    function card(host, name, recipe) {
        const node = text('article', null, 'db-entry');
        if (D.valid(recipe)) {
            const preview = button('', () => {
                modal(name, [], tr('closePreview'), () => {});
                $('modal').classList.add('db-preview-dialog');
                $('modal-body').appendChild(recipePreview(recipe,name,true));
                $('cancel').hidden = true;
                $('confirm').focus();
            });
            preview.className = 'db-card-preview';
            preview.setAttribute('aria-label',tr('openNamedPreview',{name}));
            preview.appendChild(recipePreview(recipe,name,false));
            preview.appendChild(text('span','⤢','db-enlarge'));
            node.appendChild(preview);
        }
        const body = text('div', null, 'db-entry-body');
        body.appendChild(text('h3', name));
        node.appendChild(body);
        host.appendChild(node);
        return { body: body, actions: function () {
                const a = text('div', null, 'db-actions');
                body.appendChild(a);
                return a;
            } };
    }
    async function loadLibrary() {
        const seq = ++state.listRequest;
        const status = $('library-state');
        status.textContent = tr('loadingLibrary');
        try {
            const data = await api('GET', local);
            if (seq !== state.listRequest)
                return;
            if (!Array.isArray(data.items))
                throw new Error(tr('libraryError'));
            state.library = data.items;
            state.activeId = data.activeId || null;
            const host = $('saved-list');
            host.textContent = '';
            state.library.forEach(it => {
                if (!it || typeof it.id !== 'string' || !D.valid(it.recipe))
                    return;
                const c = card(host, it.name, it.recipe), summary = [D.templates[it.recipe.template][0]];
                if (it.id === state.activeId)
                    summary.push(tr('selectedCluster'));
                if (it.communityId)
                    summary.push(it.source === 'community' ? tr('communityCopy') : tr('published'));
                c.body.appendChild(text('p', summary.join(' · ')));
                const a = c.actions();
                a.appendChild(button(tr('edit'), () => {
                    if (state.id === it.id && dirty())
                        show('design');
                    else
                        changeDoc(() => enter(it.name, it.recipe, it.id, it.revision));
                }));
                if (state.id === it.id && dirty())
                    a.appendChild(button(tr('reloadSaved'), () => changeDoc(() => enter(it.name, it.recipe, it.id, it.revision))));
                a.appendChild(button(tr('apply'), () => run(async () => {
                    await api('POST', local + '/' + encodeURIComponent(it.id) + '/apply', {});
                    await loadLibrary();
                    tell(tr('applied'));
                })));
                a.appendChild(button(it.communityId && it.source !== 'community' ? tr('updateListing') : tr('publish'), () => publish(it)));
                a.appendChild(button(tr('delete'), () => modal(tr('confirmDelete', {name: it.name}), [], tr('delete'), () => run(async () => {
                    await api('DELETE', local + '/' + encodeURIComponent(it.id));
                    if (state.id === it.id) {
                        state.id = null;
                        state.revision = null;
                        state.baseline = '';
                        remember();
                    }
                    await loadLibrary();
                    tell(tr('deleted'));
                }), tr('deleteDescription'))));
            });
            status.textContent = host.children.length ? '' : tr('emptyLibrary');
        }
        catch (e) {
            if (seq === state.listRequest)
                status.textContent = e.message;
        }
    }
    async function publish(it) {
        const editing = !!it.communityId && it.source === 'local';
        const request = ++publishRequest;
        let listing = {};
        if (editing) {
            try {
                const data = await api('GET', community + 'item/' + encodeURIComponent(it.communityId));
                listing = data.item || {};
            } catch (e) {
                if (e.status !== 404) {
                    if (request === publishRequest) tell(e.message, true);
                    return;
                }
            }
        }
        if (state.page !== 'library' || request !== publishRequest) return;
        modal(editing ? tr('editListing') : tr('publishCommunity'), [
            { key: 'author', label: tr('publicAuthor'), required: true, max: 40, value: listing.authorName || read('od.dashboard.author') || '' },
            { key: 'about', label: tr('descriptionOptional'), max: 500, multiline: true, value: listing.description || '' }
        ], tr('publish'), v => run(async () => {
            await api('POST', community + 'publish', { id: it.id, authorName: v.author, description: v.about });
            store('od.dashboard.author', v.author);
            await loadLibrary();
            tell(tr('publishedCommunity'));
        }), tr('publicDescription', {name: it.name}));
    }
    async function loadCommunity(reset) {
        const seq = ++state.publicRequest, status = $('community-state');
        if (reset) {
            state.next = null;
            state.publicItems = [];
            $('public-list').textContent = '';
        }
        status.textContent = tr('loadingCommunity');
        $('more').hidden = true;
        try {
            const query = new URLSearchParams({ q: $('search').value.trim(), sort: $('sort').value, pageSize: '12' });
            if (!reset && state.next)
                query.set('cursor', state.next);
            const data = await api('GET', community + 'list?' + query);
            if (seq !== state.publicRequest)
                return;
            if (!Array.isArray(data.items))
                throw new Error(tr('communityError'));
            const seen = new Set(state.publicItems.map(it => it.id));
            data.items.forEach(it => {
                if (it && typeof it.id === 'string' && !seen.has(it.id)) {
                    state.publicItems.push(it);
                    seen.add(it.id);
                }
            });
            state.next = data.nextCursor || null;
            renderCommunity();
            $('more').hidden = !state.next;
            status.textContent = state.publicItems.length ? '' : tr('noMatches');
        }
        catch (e) {
            if (seq === state.publicRequest) {
                status.textContent = e.message;
                $('more').hidden = !state.next;
            }
        }
    }
    function renderCommunity() {
        const host = $('public-list');
        host.textContent = '';
        state.publicItems.forEach(it => {
            const c = card(host, it.name, it.dashboard);
            const summary = [];
            if (it.authorName)
                summary.push(tr('byAuthor', {author: it.authorName}));
            if (it.ratingCount && typeof it.ratingAvg === 'number')
                summary.push(it.ratingAvg.toFixed(1) + ' ★');
            if (it.downloads)
                summary.push(tr('imports', {count: it.downloads}));
            if (summary.length)
                c.body.appendChild(text('p', summary.join(' · ')));
            if (it.description)
                c.body.appendChild(text('p', it.description));
            const a = c.actions(), key = encodeURIComponent(it.id);
            a.appendChild(button(tr('addToLibrary'), () => run(async () => {
                const item = identify(await api('POST', community + 'import/' + key, {}));
                tell(tr('addedToLibrary', {name: item.name}));
            })));
            a.appendChild(button(tr('rate'), () => modal(tr('rateName', {name: it.name}), [{ key: 'stars', label: tr('rating'), options: [1, 2, 3, 4, 5].map(n => [String(n), n + ' / 5']), value: '5' }], tr('rate'), v => run(async () => {
                await api('POST', community + 'rate/' + key, { stars: Number(v.stars) });
                await loadCommunity(true);
                tell(tr('ratingSaved'));
            }))));
            if (it.mine)
                a.appendChild(button(tr('unpublish'), () => modal(tr('confirmUnpublish', {name: it.name}), [], tr('unpublish'), () => run(async () => {
                    await api('DELETE', community + 'item/' + key);
                    await loadCommunity(true);
                    tell(tr('unpublished'));
                }))));
            else
                a.appendChild(button(tr('report'), () => modal(tr('reportName', {name: it.name}), [{ key: 'reason', label: tr('reason'), max: 200, multiline: true, required: true }], tr('report'), v => run(async () => {
                    await api('POST', community + 'report/' + key, { reason: v.reason });
                    tell(tr('reported'));
                }))));
        });
    }
    function signalOptions(catalog) {
        const select=$('signal'), groups=new Map(), previous=select.value;
        select.textContent='';
        Object.entries(D.signals).forEach(([key,s])=>{
            const entry=catalog.find(it=>it && it.key===key && it.type==='number');
            const translated=entry && entry.labelKey && window.BYD && BYD.i18n && BYD.i18n.t && BYD.i18n.t(entry.labelKey);
            state.signalLabels[key]=translated && translated!==entry.labelKey ? String(translated) : s.label;
            if (!groups.has(s.group)) {
                const group=document.createElement('optgroup');
                group.label=s.group;
                groups.set(s.group,group);
                select.appendChild(group);
            }
            groups.get(s.group).appendChild(new Option(signalLabel(key),key));
        });
        select.value=(widget() && widget().signal) || previous || 'soc';
    }
    async function loadPreviewPreferences() {
        const [catalog,data]=await Promise.all(['/api/widgets/signals','/api/widgets/values'].map(path=>api('GET',path).catch(()=>null)));
        if (catalog && Array.isArray(catalog.signals)) {
            state.signalCatalog = catalog.signals;
            signalOptions(state.signalCatalog);
        }
        if (catalog && catalog.units) {
            const u=catalog.units;
            state.units={distance:u.distance==='mi'?'mi':'km',tyre:['bar','kpa','psi'].includes(u.tyre)?u.tyre:'psi'};
        }
        // Only the currency code is used; the preview itself always uses sample readings.
        if (data && data.values) {
            const unit=data.values.currency;
            state.currency=typeof unit==='string' && unit.trim() ? unit.trim() : null;
        }
        draw(); redrawCards(); inspector();
    }
    function refreshChoices() {
        options($('accent'), entries(D.accents), state.recipe.accent);
        options($('face'), entries(D.faces), widget() && widget().type);
        options($('background'), entries(D.backgrounds), state.recipe.background || 'template');
        signalOptions(state.signalCatalog);
        $('swatches').querySelectorAll('[data-accent]').forEach(b => {
            const label = D.accents[b.dataset.accent];
            b.title = label;
            b.setAttribute('aria-label', label);
        });
    }
    function restoreDraft() {
        state.name = tr('defaultName');
        state.baseline = signature();
        const saved = read('od.dashboard.work.v1', true) || read('od.dashboard.work.v1');
        if (saved && D.valid(saved.recipe) && typeof saved.name === 'string') {
            state.recipe = saved.recipe;
            state.name = saved.name.slice(0, 60);
            state.id = typeof saved.id === 'string' ? saved.id : null;
            state.revision = Number.isInteger(saved.revision) ? saved.revision : null;
            state.baseline = typeof saved.baseline === 'string' ? saved.baseline : '';
        }
        $('name').value = state.name;
        $('name').oninput = () => {
            state.name = $('name').value;
            mark();
        };
    }
    function init() {
        if (state.name == null && !dirty()) {
            state.name = tr('defaultName');
            state.baseline = signature();
        }
        if (dirty()) tell(tr('restored'));
        options($('template'), entries(D.templates).map(r => [r[0], r[1][0]]));
        refreshChoices();
        $('background').onchange=()=>{
            const background=$('background').value;
            if (background===(state.recipe.background || 'template')) return;
            D.upgrade(state.recipe); state.recipe.background=background; editor(); mark();
        };
        $('edit-mode').querySelectorAll('button').forEach(b=>b.onclick=()=>{
            if (state.mode===b.dataset.mode) return;
            state.mode=b.dataset.mode;
            if (cameraMode()) {
                state.priorScenario=state.scenario;
                chooseCamera(state.camera);
            } else {
                state.scenario=state.priorScenario || 'drive'; $('scenario').value=state.scenario;
            }
            editor();
        });
        $('camera-tools').querySelectorAll('[data-side]').forEach(b=>b.onclick=()=>pick(b.dataset.side));
        $('camera-reset').onclick=()=>{
            const cameras=state.recipe.cameras;
            if (!cameras || !cameras[state.camera]) return;
            delete cameras[state.camera];
            if (!Object.keys(cameras).length) delete state.recipe.cameras;
            editor(); mark();
        };
        $('face').onchange=()=>{ const w=widget(); if(w && w.signal) { w.type=$('face').value; editor(); mark(); } };
        $('signal').onchange=()=>{ const w=widget(); if(w && w.signal) { w.signal=$('signal').value; editor(); mark(); } };
        $('convert').onclick=()=>{
            const w=widget();
            if (w.type==='speed') {
                $('add-kind').value='gauge'; $('add').click();
                return;
            }
            if (w.type!=='power' && w.type!=='range') return;
            D.upgrade(state.recipe);
            w.signal=w.type==='power'?'power':'range_km';
            w.type='gauge';
            editor(); mark(); $('signal').focus();
        };
        entries(D.templates).forEach(([key, meta]) => {
            const b = button('', () => {
                if (state.recipe.template === key) return;
                $('template').value = key; $('template').onchange();
            });
            b.dataset.template = key;
            const image = document.createElement('img');
            presetImage(image,key); image.alt = '';
            b.appendChild(image); b.appendChild(text('b', meta[0])); $('templates').appendChild(b);
        });
        entries(D.accents).forEach(([key, name]) => {
            const b = button('', () => { $('accent').value = key; $('accent').onchange(); });
            b.className = 'db-swatch'; b.dataset.accent = key; b.title = name;
            b.setAttribute('aria-label', name);
            b.style.setProperty('--chip-colour', D.colours[key] || 'linear-gradient(135deg,#90ceec,#7b9982,#cfac94)');
            $('swatches').appendChild(b);
        });
        $('next').onclick = () => $('templates').scrollBy(240, 0);
        $('previous').onclick = () => $('templates').scrollBy(-240, 0);
        $('light-choices').querySelectorAll('button').forEach(b => b.onclick = () => { $('theme').value = b.dataset.value; $('theme').onchange(); });
        $('front').onclick = () => shiftLayer(1); $('back').onclick = () => shiftLayer(-1);
        $('undo').onclick = () => moveHistory(true); $('redo').onclick = () => moveHistory(false);
        $('expand').onclick = () => { D.fullCanvas(state.recipe); editor(); mark(); };
        $('add-menu').onclick = () => { const list = $('add-list'); list.hidden = !list.hidden; $('add-menu').setAttribute('aria-expanded', String(!list.hidden)); };
        $('accent').onchange = () => {
            state.recipe.accent = $('accent').value;
            editor();
            mark();
        };
        $('template').onchange = () => {
            const key = $('template').value;
            if (key === state.recipe.template) return;
            const starter = D.initial(state.recipe.template);
            const rearranged = JSON.stringify(state.recipe.widgets) !== JSON.stringify(starter.widgets) || state.recipe.space !== starter.space;
            const apply = retain => {
                if (retain) state.recipe.template = key;
                else {
                    const next = D.initial(key); next.accent = state.recipe.accent;
                    if (state.recipe.version===2) {
                        D.upgrade(next); next.background=state.recipe.background;
                        if (state.recipe.cameras) next.cameras=copy(state.recipe.cameras);
                    }
                    state.recipe = next;
                    state.selected=speedIndex();
                }
                editor(); mark();
            };
            if (rearranged) {
                $('template').value = state.recipe.template;
                modal(tr('changeStartingDesign'), [{key:'layout',label:tr('instrumentPositions'),options:[['keep',tr('keepPositions')],['preset',tr('usePresetPositions')]]}], tr('changeDesign'), v => apply(v.layout === 'keep'));
            } else apply(false);
        };
        $('new').onclick = () => changeDoc(() => modal(tr('newDashboard'), [{ key: 'name', label: tr('dashboardName'), max: 60, required: true, value: tr('defaultName') }, { key: 'template', label: tr('startingDesign'), options: entries(D.templates).map(r => [r[0], r[1][0]]), value: state.recipe.template }], tr('create'), v => {
            enter(v.name, D.initial(v.template), null, null);
            state.baseline = '';
            mark();
        }));
        $('save').onclick = () => run(() => save(false));
        $('copy').onclick = () => run(() => save(true));
        $('selected').onchange = () => pick($('selected').value);
        $('add').onclick = () => {
            const w = D.addSlot(state.recipe, $('add-kind').value);
            if (!w) {
                tell(tr('limitReached'), true);
                return;
            }
            if (w.signal) D.upgrade(state.recipe);
            state.recipe.widgets.push(w);
            state.selected=state.recipe.widgets.length-1;
            editor();
            mark();
            if (w.signal) $('signal').focus();
        };
        $('remove').onclick = () => {
            const w = widget();
            if (!w || w.type === 'speed')
                return;
            state.recipe.widgets = state.recipe.widgets.filter(item => item !== w);
            state.selected=speedIndex();
            editor();
            mark();
        };
        ['x', 'y', 'w', 'h'].forEach(k => $(k).onchange = geometryEdit);
        bindHandles();
        document.addEventListener('keydown', e => {
            if (!(e.metaKey || e.ctrlKey) || e.key.toLowerCase() !== 'z' || e.target.closest('input,textarea,select') || !$('modal').hidden || state.page !== 'design') return;
            e.preventDefault(); moveHistory(!e.shiftKey);
        });
        $('height').onchange = () => {
            state.panel = Number($('height').value);
            editor();
        };
        $('theme').onchange = () => {
            state.theme = $('theme').value;
            editor();
        };
        $('scenario').onchange = () => {
            state.scenario = $('scenario').value;
            if (cameraMode()) {
                const side=state.scenario.split('-')[0];
                if (side==='left' || side==='right') state.camera=side; else state.mode='widgets';
                inspector(); handles();
            }
            draw();
        };
        document.querySelectorAll('#db .db-nav button').forEach(b => b.onclick = () => { if (b.dataset.page !== state.page)
            show(b.dataset.page); });
        $('cancel').onclick = closeModal;
        $('confirm').onclick = () => { if (modalAction)
            modalAction(); };
        $('modal').onkeydown = e => {
            if (e.key === 'Escape') {
                e.preventDefault();
                closeModal();
            }
            else if (e.key === 'Tab') {
                const f = $('modal').querySelectorAll('input:not([hidden]),textarea:not([hidden]),select:not([hidden]),button:not([hidden])');
                if (e.shiftKey && document.activeElement === f[0]) {
                    e.preventDefault();
                    f[f.length - 1].focus();
                }
                else if (!e.shiftKey && document.activeElement === f[f.length - 1]) {
                    e.preventDefault();
                    f[0].focus();
                }
            }
        };
        $('refresh-library').onclick = loadLibrary;
        $('refresh-community').onclick = () => loadCommunity(true);
        $('sort').onchange = () => loadCommunity(true);
        $('search').oninput = () => {
            clearTimeout(filterTimer);
            filterTimer = setTimeout(() => loadCommunity(true), 300);
        };
        $('more').onclick = () => { if (state.next)
            loadCommunity(false); };
        lastEdit = signature(); historyButtons(); editor();
        BYD.i18n.onChange(() => {
            refreshChoices();
            editor();
            if (state.page === 'library') loadLibrary();
            if (state.page === 'community') renderCommunity();
        });
        loadPreviewPreferences();
        window.addEventListener('hashchange', () => {
            const page = location.hash.slice(1);
            if (['design', 'library', 'community'].includes(page) && page !== state.page) show(page);
        });
        const editId = new URLSearchParams(location.search).get('edit');
        if (editId) {
            const link = new URL(location.href);
            link.searchParams.delete('edit');
            history.replaceState(null, '', link.pathname + link.search + link.hash);
            const generation = documentGeneration, navigation = navigationGeneration;
            if (editId === state.id && dirty()) return;
            run(async () => {
                const item = identify(await api('GET', local + '/' + encodeURIComponent(editId)));
                if (generation === documentGeneration && navigation === navigationGeneration)
                    changeDoc(() => enter(item.name, item.recipe, item.id, item.revision));
            });
        }
        else {
            const target = location.hash.slice(1);
            if (target === 'library' || target === 'community')
                show(target);
        }
    }
    // A language fetch can outlive the page's load event. Restore the
    // private draft before that fetch so typing or reloading cannot lose it.
    restoreDraft();
    BYD.i18n.init().then(init);
})();
