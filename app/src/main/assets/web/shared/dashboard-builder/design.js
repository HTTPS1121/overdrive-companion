/* Coordinates are thousandths of the document's instrument area; camera slots always use the full panel. */
(function () {
    'use strict';
    const templates = {
        motorcourt: ['Motorcourt', 'drive', 'sleeve', '#ddb77e'],
        'cobalt-pair': ['Cobalt Pair', 'dual', 'record', '#72b4ff'],
        yawline: ['Yawline', 'race', 'signal', '#f39387'],
        nightwater: ['Nightwater', 'halo', 'ambient', '#86dfcd'],
        miler: ['Miler', 'drive', 'ribbon', '#89b9e1'],
        'ion-trio': ['Ion Trio', 'rings', 'record', '#7acebd'],
        crosscheck: ['Crosscheck', 'rings', 'signal', '#78b4ff'],
        'navy-quadrant': ['Navy Quadrant', 'dual', 'console', '#799fcf'],
        laneform: ['Laneform', 'drive', 'ambient', '#81c8b6'],
        cutline: ['Cutline', 'race', 'ribbon', '#ef857f'],
        longhand: ['Longhand', 'dual', 'record', '#e4887a'],
        'flux-ledger': ['Flux Ledger', 'rings', 'console', '#77b7ef'],
        'brass-mile': ['Brass Mile', 'dual', 'sleeve', '#d4a06f']
    };
    function translated(key, fallback, vars) {
        const i18n = window.BYD && window.BYD.i18n;
        const fullKey = 'dashboardBuilder.' + key;
        const value = i18n && i18n.t(fullKey, vars);
        if (typeof value === 'string' && value !== fullKey) return value;
        return vars ? fallback.replace(/\{(\w+)\}/g, (match, name) => vars[name] == null ? match : vars[name]) : fallback;
    }
    function translatedChoices(section, english) {
        const choices = {};
        for (const key of Object.keys(english)) {
            Object.defineProperty(choices, key, { enumerable: true, get: () => translated(section + '.' + key, english[key]) });
        }
        return choices;
    }
    const accents = translatedChoices('accents', { auto: 'Template colour', ice: 'Ice', mint: 'Mint', amber: 'Amber', rose: 'Rose', indigo: 'Indigo' });
    const colours = { ice: '#77c6e9', mint: '#78d8af', amber: '#eab567', rose: '#e79aa5', indigo: '#aaa1ed' };
    const kinds = translatedChoices('kinds', { speed: 'Speed', power: 'Power', range: 'Range', gear: 'Gear', music: 'Music', trip: 'Trip', tyres: 'Tyres', nav: 'Navigation' });
    const faces = translatedChoices('faces', { reading: 'Number', gauge: 'Gauge', bar: 'Bar', trend: 'Trend' });
    const backgrounds = translatedChoices('backgrounds', { template: 'Starting design', aurora: 'Aurora', road: 'Driving scene', plain: 'Plain' });
    const signalGroups = translatedChoices('signalGroups', { energy: 'Energy & range', driving: 'Driving', trip: 'Trip', tyres: 'Tyres' });
    const signals = {};
    function signal(key, label, group, unit, min, max, sample) {
        signals[key] = {
            get label() { return translated('signals.' + key, label); },
            get group() { return signalGroups[group]; },
            unit, min, max, sample
        };
    }
    signal('soc', 'Battery charge', 'energy', '%', 0, 100, 74);
    signal('electric_range_km', 'Electric range', 'energy', 'km', 0, 1000, 60);
    signal('fuel_range_km', 'Fuel range', 'energy', 'km', 0, 1000, 311);
    signal('range_km', 'Total range', 'energy', 'km', 0, 1500, 371);
    signal('fuel_pct', 'Fuel level', 'energy', '%', 0, 100, 48);
    signal('speed', 'Speed', 'driving', 'km/h', 0, 250, 72);
    signal('power', 'Power', 'driving', 'kW', -150, 300, 34);
    signal('trip_km', 'Trip distance', 'trip', 'km', 0, 1000, 17.2);
    signal('trip_minutes', 'Trip time', 'trip', 'min', 0, 1440, 29);
    signal('trip_kwh', 'Trip energy', 'trip', 'kWh', 0, 150, 4.3);
    signal('trip_top_kmh', 'Trip top speed', 'trip', 'km/h', 0, 250, 65);
    signal('trip_cost', 'Trip cost', 'trip', 'currency', 0, 1000, 27.45);
    signal('tyre_fl', 'Front-left tyre', 'tyres', 'bar', 0, 4, 2.42);
    signal('tyre_fr', 'Front-right tyre', 'tyres', 'bar', 0, 4, 2.41);
    signal('tyre_rl', 'Rear-left tyre', 'tyres', 'bar', 0, 4, 2.39);
    signal('tyre_rr', 'Rear-right tyre', 'tyres', 'bar', 0, 4, 2.40);
    const owned = (o, k) => Object.prototype.hasOwnProperty.call(o, k);
    const exact = (o, fields) => o && typeof o === 'object' && !Array.isArray(o)
        && Object.keys(o).length === fields.length && fields.every(k => owned(o, k));
    const bounds = { x: .03, y: .22, w: .94, h: .61 };
    // The reviewed 1920 × 480 placements from ReviewGeometry. Built-in-only auxiliary gauges stay with their preset.
    const compositions = {
        'motorcourt': [['speed',56,70,290,150], ['power',64,234,385,70], ['trip',64,314,445,85], ['range',1450,307,412,105], ['music',1458,146,386,139]],
        'cobalt-pair': [['power',107,47,386,386], ['speed',1427,47,386,386], ['trip',680,68,555,61], ['music',675,148,570,190], ['range',747,371,425,59]],
        'longhand': [['speed',372,48,376,376], ['power',1172,48,376,376], ['gear',850,95,220,118], ['music',748,260,424,94], ['range',34,310,245,99], ['trip',752,366,416,55]],
        'navy-quadrant': [['power',367,63,346,346], ['speed',1207,63,346,346], ['gear',808,128,304,85], ['music',773,230,374,145], ['trip',745,384,430,54]],
        'flux-ledger': [['power',271,93,318,318], ['speed',1331,93,318,318], ['trip',735,94,450,105], ['music',740,226,440,92], ['range',750,350,420,65]],
        'brass-mile': [['power',148,58,364,364], ['speed',1408,58,364,364], ['gear',692,73,536,56], ['music',656,169,608,161], ['trip',668,343,584,74]],
        'nightwater': [['speed',857,71,302,302], ['music',1370,161,440,94], ['range',1500,374,349,72], ['trip',78,374,565,75]],
        'ion-trio': [['range',190,104,280,280], ['speed',782,66,356,356], ['music',1125,76,320,72], ['trip',86,396,461,63]],
        'yawline': [['speed',472,90,652,288], ['power',67,91,306,115], ['trip',66,229,353,66], ['music',70,315,330,76]],
        'miler': [['speed',1405,82,300,300], ['music',86,374,285,72], ['nav',373,191,365,96], ['trip',394,382,370,67], ['range',1432,387,394,61]],
        'crosscheck': [['speed',825,71,270,270], ['range',1397,90,433,109], ['power',1397,219,428,81], ['trip',1397,319,436,85], ['music',757,362,406,72]],
        'laneform': [['speed',711,70,498,111], ['power',1420,107,373,247], ['nav',92,105,530,95], ['music',90,222,450,110], ['trip',568,384,428,60], ['range',1285,389,537,65]],
        'cutline': [['speed',379,80,396,289], ['power',1151,80,390,289], ['nav',1570,94,292,207], ['music',1570,322,292,78], ['range',62,250,280,102]],
    };
    const fullPanel = { x: 0, y: 0, w: 1, h: 1 };
    function area(recipe) { return recipe.space === 'panel' ? fullPanel : bounds; }
    function initial(template) {
        const widgets = compositions[template].map(([type, left, top, width, height]) => {
            const w = Math.max(type === 'speed' ? 100 : 60, Math.round(width / 1.92)), h = Math.max(type === 'speed' ? 120 : 70, Math.round(height / .48));
            const x = Math.max(0, Math.min(1000 - w, Math.round((left + width / 2) / 1.92 - w / 2)));
            const y = Math.max(0, Math.min(1000 - h, Math.round((top + height / 2) / .48 - h / 2)));
            return { type, x, y, w, h };
        });
        return { version: 1, space: 'panel', template, accent: 'auto', widgets };
    }
    function stack(widgets) { return widgets.filter(w => w.type !== 'speed').concat(widgets.filter(w => w.type === 'speed')); }
    function fullCanvas(recipe) {
        if (recipe.space === 'panel') return;
        recipe.widgets.forEach(w => {
            const x = Math.round((bounds.x + bounds.w * w.x / 1000) * 1000);
            const y = Math.round((bounds.y + bounds.h * w.y / 1000) * 1000);
            w.w = Math.max(w.type === 'speed' ? 100 : 60, Math.round(w.w * bounds.w)); w.h = Math.max(w.type === 'speed' ? 120 : 70, Math.round(w.h * bounds.h));
            w.x = Math.min(x, 1000 - w.w); w.y = Math.min(y, 1000 - w.h);
        });
        recipe.space = 'panel';
    }
    function overlap(a, b) { return a.x < b.x + b.w && b.x < a.x + a.w && a.y < b.y + b.h && b.y < a.y + a.h; }
    function minimum(recipe, type) {
        return recipe && recipe.space === 'panel' ? (type === 'speed' ? [100,120] : [60,70]) : [120,160];
    }
    function geometry(w, recipe) {
        const min = minimum(recipe, w.type);
        return [w.x, w.y, w.w, w.h].every(Number.isInteger) && w.x >= 0 && w.y >= 0 && w.w >= min[0] && w.h >= min[1] && w.x + w.w <= 1000 && w.y + w.h <= 1000;
    }
    function upgrade(recipe) {
        if (recipe.version === 1) {
            recipe.version = 2;
            recipe.background = 'template';
        }
    }
    function cameraGeometry(box) {
        return exact(box, ['x', 'y', 'w', 'h']) && Object.values(box).every(Number.isInteger) &&
            box.w >= 150 && box.w <= 500 && box.h >= 220 && box.h <= 700 &&
            box.x >= 0 && box.y >= 0 && box.x + box.w <= 1000 && box.y + box.h <= 1000;
    }
    function valid(recipe) {
        if (!recipe || (recipe.version !== 1 && recipe.version !== 2)) return false;
        const next = recipe.version === 2, fields = ['version', 'template', 'accent', 'widgets'];
        if (owned(recipe, 'space')) fields.push('space');
        if (next) fields.push('background');
        if (next && owned(recipe, 'cameras')) {
            fields.push('cameras');
            const ports = recipe.cameras;
            if (!ports || typeof ports !== 'object' || Array.isArray(ports) || !Object.keys(ports).length ||
                Object.keys(ports).some(side => !['left', 'right'].includes(side) || !cameraGeometry(ports[side]))) return false;
        }
        if (!exact(recipe, fields) || (next && (typeof recipe.background !== 'string' || !owned(backgrounds, recipe.background)))
            || (owned(recipe, 'space') && recipe.space !== 'panel') || typeof recipe.template !== 'string'
            || !owned(templates, recipe.template) || typeof recipe.accent !== 'string' || !owned(accents, recipe.accent)
            || !Array.isArray(recipe.widgets) || !recipe.widgets.length || recipe.widgets.length > (next ? 24 : 8))
            return false;
        const seen = new Set();
        return recipe.widgets.every(w => {
            if (next && w && typeof w.type === 'string' && owned(faces, w.type)) {
                return exact(w, ['type','signal','x','y','w','h']) && typeof w.signal === 'string' && owned(signals, w.signal) && geometry(w, recipe);
            }
            if (!exact(w, ['type', 'x', 'y', 'w', 'h']) || typeof w.type !== 'string' || !owned(kinds, w.type)
                || seen.has(w.type) || !geometry(w, recipe))
                return false;
            seen.add(w.type);
            return true;
        }) && seen.has('speed');
    }
    function addSlot(recipe, type) {
        const typed = owned(faces, type);
        if (recipe.widgets.length >= 24 || (!typed && (!owned(kinds, type) || recipe.widgets.some(w => w.type === type))))
            return null;
        const widget = typed ? { type, signal: type === 'trend' ? 'power' : 'soc' } : { type };
        const others = recipe.widgets;
        const xs = [0].concat(others.map(w => w.x + w.w)).sort((a, b) => a - b);
        const ys = [0].concat(others.map(w => w.y + w.h)).sort((a, b) => a - b);
        for (const size of [[245, 350], [200, 280], [160, 220], [120, 160]]) {
            for (const y of ys)
                for (const x of xs) {
                    const w = Object.assign({}, widget, { x, y, w: size[0], h: size[1] });
                    if (geometry(w, recipe) && !others.some(b => overlap(w, b)))
                        return w;
                }
        }
        const offset = (others.length % 4) * 44;
        return Object.assign(widget, { x: 285 + offset, y: 260 + offset, w: 250, h: 350 });
    }
    const art = {};
    function load(name) {
        if (!art[name]) {
            const i = new Image();
            art[name] = i;
            i.onload = () => window.dispatchEvent(new Event('dashboard-art-loaded'));
            i.src = '../shared/dashboard-builder/images/' + name + '.webp';
        }
        return art[name].naturalWidth ? art[name] : null;
    }
    function label(c, s, x, y, size, col, align, weight, maxWidth) {
        c.fillStyle = col;
        c.textAlign = align || 'center';
        c.textBaseline = 'middle';
        c.font = (weight || 500) + ' ' + Math.max(3, size) + 'px system-ui, sans-serif';
        c.fillText(s, x, y, maxWidth || 5000);
    }
    function line(c, x, y, x2, y2, color, width) {
        c.strokeStyle = color;
        c.lineWidth = width || 1;
        c.beginPath();
        c.moveTo(x, y);
        c.lineTo(x2, y2);
        c.stroke();
    }
    function arc(c, x, y, r, start, end, color, width) {
        c.strokeStyle = color;
        c.lineWidth = width;
        c.beginPath();
        c.arc(x, y, r, start, end);
        c.stroke();
    }
    function disc(c, x, y, r, color) {
        c.fillStyle = color;
        c.beginPath();
        c.arc(x, y, r, 0, Math.PI * 2);
        c.fill();
    }
    function rect(c, x, y, w, h, color) {
        c.fillStyle = color;
        c.fillRect(x, y, w, h);
    }
    function scene(c, w, h, dark, template) {
        const staged = template === 'motorcourt' || template === 'yawline';
        const cx = w * (template === 'yawline' ? .69 : template === 'crosscheck' ? .16 : .5);
        c.save();
        if (template === 'crosscheck') {
            c.beginPath(); c.rect(w * .03, h * .16, w * .26, h * .66); c.clip();
        }
        if (!staged) {
            const horizon = h * .43, bottom = h * 1.05;
            c.fillStyle = dark ? '#27323e' : '#a0aab1';
            c.beginPath(); c.moveTo(cx - 10, horizon); c.lineTo(cx + 10, horizon);
            c.lineTo(cx + w * .27, bottom); c.lineTo(cx - w * .27, bottom); c.fill();
            for (const dir of [-1, 1]) {
                c.setLineDash([4, 10]);
                line(c, cx + 3 * dir, horizon, cx + w * .17 * dir, bottom, dark ? '#8d9ca7' : '#e9f1ef', 2);
            }
            c.setLineDash([]);
        }
        const y = h * (template === 'crosscheck' ? .71 : .83);
        if (template === 'motorcourt') {
            c.strokeStyle = '#b99a70'; c.lineWidth = 2; c.beginPath();
            c.ellipse(cx, y, w * .087, h * .045, 0, 0, Math.PI * 2); c.stroke();
        }
        const car = load('vehicle');
        if (car) {
            const width = w * (template === 'yawline' ? .14 : .12), height = width * car.naturalHeight / car.naturalWidth;
            c.drawImage(car, cx - width * .5, y - height, width, height);
        }
        c.restore();
    }
    // Same factory camera slots as ReviewGeometry. The simulator paints a sample view in the native slot.
    function cameraSlot(tpl, panel, left) {
        const compact = panel === 480;
        const rings = {
            'cobalt-pair': compact ? [300,240,193,1620,240,193] : [352,370,274,1568,370,274],
            'longhand': compact ? [560,236,188,1360,236,188] : [430,362,278,1490,362,278],
            'navy-quadrant': compact ? [540,236,173,1380,236,173] : [520,334,246,1400,334,246],
            'flux-ledger': compact ? [430,252,159,1490,252,159] : [440,380,220,1480,380,220],
            'brass-mile': compact ? [330,240,182,1590,240,182] : [360,352,267,1560,352,267],
            'nightwater': compact ? [341,219,106,1579,219,106] : [353,311,141,1567,311,141],
            'ion-trio': compact ? [330,244,140,1590,244,142] : [310,380,210,1610,380,214],
            'miler': compact ? [236,273,91] : [260,438,130]
        };
        if (owned(rings, tpl) && (tpl !== 'miler' || left)) {
            const start = left ? 0 : 3, row = rings[tpl];
            const r = row[start + 2] * (['cobalt-pair','longhand','navy-quadrant','flux-ledger','brass-mile'].indexOf(tpl) >= 0 ? .66 : 1);
            return [row[start] - r, row[start + 1] - r, 2*r, 2*r, true];
        }
        if (tpl === 'crosscheck') {
            return compact ? [left ? 64 : 1376, 78, 480, 316, false] : [left ? 60 : 1340, 100, 520, 465, false];
        }
        if (tpl === 'miler') return compact ? [1135,157,330,208,false] : [1090,245,412,260,false];
        return compact ? [left ? 70 : 1495,106,355,220,false] : [left ? 70 : 1425,174,425,275,false];
    }
    function cameraFrame(recipe, panel, side) {
        const custom = recipe.cameras && recipe.cameras[side];
        if (custom) return [custom.x * 1.92, custom.y * panel / 1000, custom.w * 1.92, custom.h * panel / 1000, false];
        return cameraSlot(recipe.template, panel, side === 'left');
    }
    function editableCamera(recipe, panel, side) {
        if (recipe.cameras && recipe.cameras[side]) return recipe.cameras[side];
        const [left, top, width, height] = cameraFrame(recipe, panel, side);
        const w = Math.max(150, Math.min(500, Math.round(width / 1.92)));
        const h = Math.max(220, Math.min(700, Math.round(height * 1000 / panel)));
        return {
            x: Math.max(0, Math.min(1000 - w, Math.round((left + width / 2) / 1.92 - w / 2))),
            y: Math.max(0, Math.min(1000 - h, Math.round((top + height / 2) * 1000 / panel - h / 2))), w, h
        };
    }
    // Mirrors CameraHudPlacement, in native 1920-wide coordinates. Real camera video sits above the HUD.
    function cameraHud(panel, camera, custom, withAlert) {
        const small=panel===480, at=(a,b)=>small?a:b, box=(x,y,w,h)=>({x,y,w,h});
        const home={
            alert:box(662,at(6,12),596,at(82,100)), warning:box(1227,at(6,26),128,109),
            left:box(at(40,92),at(18,52),at(330,356),at(58,62)),
            right:box(at(1450,1376),at(18,52),at(430,452),at(58,62)),
            hazard:box(at(386,100),at(24,6),at(256,336),44), gear:box(887,at(427,661),146,at(39,44)),
            limit:box(618,at(425,652),at(36,40),at(36,40)),acc:box(675,at(424,656),137,42),
            speed:box(withAlert?1095:845,withAlert?at(400,632):at(11,20),230,at(63,80))
        };
        const placed=Object.assign({},home);
        if (camera && custom) {
            const obstacles=[box(...camera.slice(0,4))];
            function closest(slot,w,h,occupied) {
                const clear=r=>occupied.every(o=>r.x>=o.x+o.w+2 || r.x+w+2<=o.x || r.y>=o.y+o.h+2 || r.y+h+2<=o.y);
                const start=box(slot.x,slot.y,w,h);
                if (clear(start)) return start;
                const xs=[slot.x,0,1920-w],ys=[slot.y,0,panel-h];
                for (const o of occupied) { xs.push(o.x-w-5,o.x+o.w+5); ys.push(o.y-h-5,o.y+o.h+5); }
                let distance=Infinity, nearest=null;
                for(const x of xs) for(const y of ys) {
                    const r=box(x,y,w,h), delta=(x-slot.x)**2+(y-slot.y)**2;
                    if(x>=0 && y>=0 && x+w<=1920 && y+h<=panel && delta<distance && clear(r)) {
                        nearest=r; distance=delta;
                    }
                }
                return nearest;
            }
            for (const key of Object.keys(home)) {
                if (key==='alert' && !withAlert) continue;
                const slot=home[key];
                let dock=null;
                for (let percent=100;percent>=60&&!dock;percent-=5) {
                    dock=closest(slot,slot.w*percent/100,slot.h*percent/100,obstacles);
                }
                placed[key]=dock || closest(slot,slot.w*.6,slot.h*.6,[obstacles[0]]);
                obstacles.push(placed[key]);
            }
        }
        return {home,placed};
    }
    function formatReading(key, value, p) {
        if (!Number.isFinite(value)) return '—';
        const u = signals[key].unit, unit = p.units || {}, miles = unit.distance === 'mi';
        if (u === 'currency') {
            const unit=typeof p.currency === 'string' ? p.currency.trim() : '';
            if (!unit || value < 0) return '—';
            const last=unit.slice(-1), gap=last.toLocaleUpperCase()!==last.toLocaleLowerCase() ? '\u00a0' : '';
            return unit+gap+value.toFixed(2);
        }
        if (u === 'bar') {
            const kpa = Math.round(value * 100);
            if (unit.tyre === 'bar') return (kpa / 100).toFixed(1) + ' bar';
            if (unit.tyre === 'kpa') return kpa + ' kPa';
            return (kpa * .1450377).toFixed(1) + ' psi';
        }
        if (u === 'km' || u === 'km/h') {
            const distance = miles ? value * .621371192 : value;
            return (key === 'trip_km' ? distance.toFixed(1) : String(Math.round(distance))) + ' ' + (miles ? (u === 'km' ? 'mi' : 'mph') : u);
        }
        return (key === 'trip_kwh' ? value.toFixed(1) : String(Math.round(value))) + (u === '%' ? '' : ' ') + u;
    }
    function sampleValue(key, p) {
        if (p.missing) return null;
        if (p.readings && owned(p.readings, key)) return p.readings[key];
        if (key === 'speed') return p.speed;
        if (key === 'power') return p.power;
        return signals[key].sample;
    }
    function readingFace(c, b, p) {
        const {x,y,w,h,signal:key,type} = b, s = signals[key];
        const v = sampleValue(key,p), text = formatReading(key, v, p), pad = Math.min(w*.075,h*.105);
        const cx = x+w/2, cy = y+h*.49, radius = Math.min(w*.41,h*.425);
        const edge = p.dark?'rgba(231,242,237,.08)':'rgba(16,28,24,.10)';
        const caption = p.labels && p.labels[key] || s.label;
        c.beginPath();
        const corner = Math.min(14*p.scale,h*.16,w*.16);
        if (c.roundRect) c.roundRect(x+1,y+1,Math.max(1,w-2),Math.max(1,h-2),corner);
        else c.rect(x+1,y+1,w-2,h-2);
        c.fillStyle=p.dark?'rgba(4,11,9,.95)':'rgba(236,241,239,.97)';
        c.fill(); c.strokeStyle=edge; c.lineWidth=1.5*p.scale; c.stroke();
        const range = s.max - s.min, ratio = val => Math.max(0,Math.min(1,(val-s.min)/range)), zero = ratio(0);
        if (type === 'gauge') {
            const start=145*Math.PI/180, sweep=250*Math.PI/180;
            c.lineCap='round';
            arc(c,cx,cy,radius,start,start+sweep,edge,radius*.09);
            if (Number.isFinite(v) && text !== '—' && v !== 0) {
                arc(c,cx,cy,radius,start+sweep*Math.min(zero,ratio(v)),start+sweep*Math.max(zero,ratio(v)),p.accent,radius*.08);
            }
            label(c,text,cx,cy+radius*.08,Math.min(h*.21,w*.17),p.ink,'center',650,Math.min(w-pad*2,1.65*radius));
            label(c,caption,cx,y+h*.89,Math.min(h*.12,w*.105),p.sub,'center',600,w-pad*2);
            return;
        }
        label(c,caption,x+pad,y+h*.23,Math.min(h*.18,w*.115,29*p.scale),p.sub,'left',550,w-pad*2);
        label(c,text,x+pad,y+h*(type==='reading'?.64:.51),Math.min(h*(type==='reading'?.42:.32),w*.24),p.ink,'left',650,w-pad*2);
        const left=x+pad,right=x+w-pad,base=y+h*.82;
        if (type === 'bar') {
            line(c,left,base,right,base,p.edge,Math.max(2,h*.055));
            const origin=left+(right-left)*zero;
            if (Number.isFinite(v) && text !== '—') line(c,origin,base,left+(right-left)*ratio(v),base,p.accent,Math.max(2,h*.055));
            if(s.min<0)line(c,origin,base-h*.065,origin,base+h*.065,p.sub,Math.max(1,p.scale));
        } else if (type === 'trend') {
            line(c,left,y+h*.92,right,y+h*.92,p.edge,p.scale);
            if (!Number.isFinite(v) || text === '—') return;
            // The timeline shows representative one-minute sample data in the editor only.
            const count=28, moving = ['speed','power'].includes(key) && p.gear !== 'P';
            c.strokeStyle=p.accent;c.lineWidth=Math.max(1.5,p.scale*3);c.beginPath();
            for (let i=0;i<count;i++) {
                const z=i/(count-1), yy=base+(moving ? (.058*Math.sin(z*12)+.022*Math.sin(z*31)) : 0)*h;
                if (i===0) c.moveTo(left+(right-left)*z,yy); else c.lineTo(left+(right-left)*z,yy);
            }
            c.stroke();
        }
    }
    function cameraPreview(c, bounds, side, scale, dark) {
        const [xx,yy,w,h,round]=bounds.map((n,i)=>i<4?n*scale:n);
        // Illustrated view for arranging the slot. The projector supplies live video on the car.
        c.save();
        c.beginPath();
        if (round) c.arc(xx+w/2,yy+h/2,Math.min(w,h)/2,0,Math.PI*2);
        else c.rect(xx,yy,w,h);
        c.clip();
        c.translate(xx,yy);
        c.save();
        if (side==='left') { c.translate(w,0); c.scale(-1,1); }
        const horizon=h*.37;
        const sky=c.createLinearGradient(0,0,0,horizon);
        sky.addColorStop(0,dark?'#26344c':'#9fb8c8');sky.addColorStop(1,dark?'#667484':'#d3deda');
        rect(c,0,0,w,h,sky);
        const road=c.createLinearGradient(0,horizon,0,h);
        road.addColorStop(0,dark?'#536068':'#8c9d9e');road.addColorStop(1,dark?'#263039':'#58666b');
        rect(c,0,horizon,w,h-horizon,road);
        function band(points,colour) {
            c.fillStyle=colour;c.beginPath();
            points.forEach(([x,y],i)=>i?c.lineTo(x*w,y*h):c.moveTo(x*w,y*h));c.closePath();c.fill();
        }
        band([[0,.29],[.11,.19],[.20,.28],[.35,.23],[.53,.34],[.7,.36],[1,.37],[1,.39],[0,.41]],dark?'#384746':'#738b82');
        band([[0,.34],[.62,.365],[0,.49]],dark?'#829196':'#c9d5d2');
        band([[0,.39],[.62,.367],[0,.43]],dark?'#4c5862':'#89999b');
        for (let i=0;i<4;i++) {
            const z=(i+1)/4, start=z*z*.62, end=Math.max(0,start-(.018+.15*z*z));
            band([[.66-start*.58,.38+start],[.66-end*.58,.38+end],[.66-end*.5,.38+end],[.66-start*.5,.38+start]],dark?'#b8bdbe':'#e0e6df');
        }
        band([[1,.17],[.96,.22],[.9,.48],[.84,1],[1,1]],dark?'#142027':'#536773');
        band([[.98,.24],[.94,.33],[.88,.63],[.87,.69],[.93,.51]],dark?'#6e8797':'#a9bdc6');
        c.restore();
        c.translate(-xx,-yy);
        const chipW=Math.min(w*.72,h*.98), chipH=Math.min(h*.19,w*.14);
        rect(c,xx+(w-chipW)/2,yy+h*.74,chipW,chipH,'rgba(12,22,28,.79)');
        label(c, side==='left'?translated('leftCamera','Left camera'):translated('rightCamera','Right camera'),xx+w/2,yy+h*.74+chipH*.53,chipH*.61,'#f1f5f4','center',550,chipW*.88);
        c.restore();
    }
    function dial(c, x, y, w, h, type, tpl, p) {
        const power = type === 'power', miles = p.units && p.units.distance === 'mi';
        const value = power ? p.power : Math.round(p.speed * (miles ? .621371192 : 1)), unit = power ? 'kW' : miles ? 'mph' : 'km/h';
        const cx = x + w / 2, cy = y + h / 2, r = Math.min(w, h) * .486;
        const start = Math.PI * .75, sweep = Math.PI * 1.5;
        const min = power && !['navy-quadrant','brass-mile'].includes(tpl) ? -100 : 0;
        const max = power ? (tpl === 'navy-quadrant' ? 300 : 250) : (miles ? 140 : tpl === 'brass-mile' ? 220 : ['navy-quadrant','ion-trio'].includes(tpl) ? 200 : 240);
        const angle = val => start + sweep * (val - min) / (max - min);
        if (tpl === 'cutline') {
            const dir = power ? -1 : 1, anchor = x + w * (power ? .94 : .06);
            for (let i=0; i<20; i++) {
                const f=i/20, xx=anchor+dir*w*f*.22, yy=y+h*(.93-f*.87);
                line(c,xx,yy,xx+dir*w*.14,yy,(value-min)/(max-min)>=f?p.accent:p.edge,h*.026);
            }
            label(c,value,cx,cy,Math.min(w*.31,h*.45),p.ink,'center',700);
            label(c,unit,cx,y+h*.68,h*.105,p.sub); return;
        }
        if (tpl==='motorcourt' || tpl==='laneform' && !power || (tpl==='yawline'||tpl==='crosscheck') && power) {
            label(c,power?kinds.power:unit,cx,y+h*.2,Math.min(16,h*.18),p.sub);
            label(c,value,cx,y+h*.6,h*.59,p.ink,'center',600);
            if (power) label(c,unit,cx,y+h*.91,h*.14,p.sub); return;
        }
        if (tpl==='laneform') {
            const rx=x+w*.19, ry=cy, rad=Math.min(h*.46,w*.49);
            arc(c,rx,ry,rad,-1.18,1.18,p.edge,1.6); arc(c,rx,ry,rad,.5,.79,p.accent,3.5);
            label(c,value,x+w*.65,cy,h*.2,p.ink); label(c,unit,x+w*.65,y+h*.67,h*.09,p.sub); return;
        }
        if (tpl==='yawline') {
            c.save(); c.translate(cx,y+h*.66); c.scale(w*.43,h*.59);
            arc(c,0,0,1,2.95,6.29,p.edge,.042);arc(c,0,0,1,2.95,2.95+3.34*value/max,p.accent,.061);c.restore();
            label(c,value,cx,y+h*.54,h*.43,p.ink,'center',600);label(c,unit,cx,y+h*.81,h*.1,p.sub); return;
        }
        const analog = ['cobalt-pair','flux-ledger','longhand','brass-mile','navy-quadrant'].includes(tpl);
        const blue = tpl==='cobalt-pair'||tpl==='flux-ledger';
        if (analog) {
            const plate=c.createRadialGradient(cx,cy-r*.3,r*.08,cx,cy-r*.3,r*1.45);
            plate.addColorStop(0,tpl==='brass-mile'?(p.dark?'#4c4036':'#efdfc5'):p.dark?'#263c50':'#e7edf2');
            plate.addColorStop(1,p.dark?'#10171b':'#adbac5');disc(c,cx,cy,r,plate);
            arc(c,cx,cy,r*.99,0,Math.PI*2,tpl==='brass-mile'?p.accent:p.edge,r*(tpl==='brass-mile'?.029:.014));
        }
        if (blue) {
            const ring=tpl==='cobalt-pair'?.29:.112, rad=r*(.95-ring/2);
            c.save();c.globalAlpha=.22;arc(c,cx,cy,rad,start,start+sweep,p.accent,r*ring);c.restore();
            const gloss=c.createLinearGradient(cx-r,cy-r,cx+r,cy+r);
            gloss.addColorStop(0,p.dark?'#bedcfc':'#487eae');gloss.addColorStop(.4,p.accent);gloss.addColorStop(1,p.dark?'#304f71':'#7facc6');
            arc(c,cx,cy,rad,angle(0),angle(value),gloss,r*ring);
        }
        const major=power?50:max<=220?20:40;
        for(let i=min;i<=max;i+=power?10:5){
            const a=angle(i),dx=Math.cos(a),dy=Math.sin(a),strong=i%major===0;
            line(c,cx+r*dx*(strong?.824:.90),cy+r*dy*(strong?.824:.90),cx+r*dx*.957,cy+r*dy*.957,strong?p.sub:p.edge,r*(strong?.012:.006));
            if((analog||tpl==='ion-trio')&&strong&&r>32){const nr=tpl==='cobalt-pair'?.573:.71;label(c,i,cx+r*dx*nr,cy+r*dy*nr,r*.095,p.sub);}
        }
        if (blue) {
            if(tpl==='cobalt-pair')arc(c,cx,cy,r*.435,0,2*Math.PI,p.edge,r*.009);
            const gearDial = tpl === 'cobalt-pair' && power && !p.separateGear;
            label(c,gearDial ? p.gear : value,cx,cy+r*.02,r*.45,p.ink,'center',600);
            label(c,gearDial ? value+' '+unit : unit,cx,cy-r*.245,r*.105,p.sub);
            if(power)label(c,translated('normalMode','NORMAL'),cx,cy+r*.28,r*.087,p.sub);
            if(tpl==='cobalt-pair'){arc(c,cx,cy,r*.91,1.065,2.077,p.edge,r*.017);if(!power)arc(c,cx,cy,r*.91,1.326,2.077,p.accent,r*.022);label(c,power?translated('regen','Regen'):'74%',cx,cy+r*.67,r*.09,p.sub);}
            return;
        }
        if (analog) {
            const dx=Math.cos(angle(value)),dy=Math.sin(angle(value));
            line(c,cx-r*.135*dx,cy-r*.135*dy,cx+r*.928*dx,cy+r*.928*dy,'#e45e55',r*.019);
            disc(c,cx,cy,r*.047,p.edge);
            label(c,value,cx,cy+r*.42,r*.26,p.ink,'center',600);label(c,unit,cx,cy+r*.63,r*.12,p.sub);return;
        }
        for(let i=0;i<40;i++){const a=start+i*sweep/40;arc(c,cx,cy,r*.977,a,a+sweep/40-.023,tpl==='nightwater'?p.edge:a<angle(value)?p.accent:p.edge,r*(tpl==='nightwater'?.013:.041));}
        label(c,value,cx,cy,r*.71,p.ink,'center',tpl==='nightwater'?450:600);
        label(c,unit,cx,cy+r*.48,r*.15,p.sub);if(!power)label(c,p.power+' kW',cx,cy-r*.4,r*.14,p.sub);
    }
    function music(c, x, y, w, h, tpl, p) {
        const style=templates[tpl][2], pad=Math.max(2,Math.min(h*.068,9)), side=Math.min(h-2*pad,w*(style==='record'?.43:.33));
        const r=side/2, cx=x+pad+r, cy=y+h*.5, coverR=r*(style==='record'?.66:style==='sleeve'||style==='console'?.92:1);
        const cover=load('album'), cut=style==='ribbon'?Math.min(h*.21,15):0, tx=x+pad+side+Math.min(h*.11,15), tw=Math.max(1,x+w-tx-pad-cut);
        if(style==='record'){
            const m=c.createLinearGradient(cx-r,cy-r,cx+r,cy+r); m.addColorStop(0,'#202a35');m.addColorStop(.4,'#728086');m.addColorStop(.65,'#171d26');m.addColorStop(1,'#647887');
            disc(c,cx,cy,r,m);for(let n=0;n<6;n++)arc(c,cx,cy,r*(.74+n*.041),0,Math.PI*2,'#21282d99',.7);
        } else if(style==='ribbon'){
            c.fillStyle=p.face;c.beginPath();c.moveTo(x,y);c.lineTo(x+w-cut,y);c.lineTo(x+w,y+h/2);c.lineTo(x+w-cut,y+h);c.lineTo(x,y+h);c.closePath();c.fill();
        } else if(style==='ambient'){
            c.fillStyle=p.face;c.beginPath();c.ellipse(x+w/2,y+h/2,w/2,h/2,0,0,Math.PI*2);c.fill();
        } else if(style==='signal'){line(c,tx,y+2,x+w-pad,y+2,p.edge,1);}
        else rect(c,x+1,y+1,w-2,h-2,style==='sleeve'?(p.dark?'#342822':'#e3d2bc'):p.face);
        c.save();c.translate(cx,cy);
        if(style==='sleeve'){c.rotate(-.042);rect(c,-r,-r,side,side,'#eedbb8');}
        if(style==='record'){c.beginPath();c.arc(0,0,coverR,0,2*Math.PI);c.clip();}
        if(cover){const sw=Math.min(cover.width,cover.height);c.drawImage(cover,(cover.width-sw)/2,(cover.height-sw)/2,sw,sw,-coverR,-coverR,2*coverR,2*coverR);}c.restore();
        const br=Math.max(3,Math.min(side*.126,10)), bx=cx+coverR-br*.75, by=cy+coverR-br*.85;
        disc(c,bx,by,br,'#09151bdc');arc(c,bx,by,br,0,2*Math.PI,'#d7e6eb',.6);
        for(const d of [-.25,.25])rect(c,bx+br*(d-.105),by-br*.4,br*.21,br*.8,'#fff');
        const size=Math.min(h*.28,tw*.16,26), times=h>=71&&tw>=80&&(style==='record'||style==='console');
        label(c,'Violet Hour',tx,y+h*(times?.33:.42),size,p.ink,'left',600,tw);
        label(c,'Amber Coast',tx,y+h*(times?.56:.69),size*.67,p.sub,'left',500,tw);
        if(times){label(c,'1:08',tx,y+h*.86,Math.min(h*.11,10),p.sub,'left');label(c,'3:26',tx+tw,y+h*.86,Math.min(h*.11,10),p.sub,'right');}
        if(style==='record'){arc(c,cx,cy,r-1,-Math.PI/2,Math.PI*.16,'#73cdae',Math.max(1.4,r*.045));}
        else if(style==='signal'){for(let j=0;j<30;j++)rect(c,tx+j*tw/30,y+h-pad-(j%5===0?4:2),tw/30-1,j%5===0?4:2,j<10?p.accent:p.edge);}
        else{line(c,tx,y+h-pad,tx+tw,y+h-pad,p.edge,1);line(c,tx,y+h-pad,tx+tw*.33,y+h-pad,p.accent,1.7);}
    }
    function instrument(c, b, tpl, p) {
        const x = b.x, y = b.y, w = b.w, h = b.h, t = b.type, cx = x + w / 2, cy = y + h / 2;
        c.save();
        c.beginPath();
        c.rect(x, y, w, h);
        c.clip();
        if (owned(faces, t))
            readingFace(c, b, p);
        if (t === 'speed' || t === 'power')
            dial(c, x, y, w, h, t, tpl, p);
        if (t === 'music')
            music(c, x, y, w, h, tpl, p);
        if (t === 'gear') {
            label(c, p.gear, cx,y+h*.46,h*.61,p.ink); label(c,translated('normalMode','NORMAL'),cx,y+h*.86,h*.15,p.sub);
        } else if (t === 'range' && tpl === 'ion-trio') {
            const r=Math.min(w,h)*.46;arc(c,cx,cy,r,2.235,7.225,p.edge,r*.05);arc(c,cx,cy,r,2.235,5.928,p.accent,r*.052);
            label(c,translated('battery','Battery'),cx,y+h*.28,h*.084,p.sub);label(c,'74%',cx,cy,h*.216,p.ink,'center',600);label(c,formatReading('range_km',371,p),cx,y+h*.715,h*.10,p.sub);
        } else if (t === 'range') {
            label(c,kinds.range,x,y+h*.18,Math.min(15,h*.24),p.sub,'left');label(c,formatReading('range_km',371,p),x+w,y+h*.20,Math.min(32,h*.33),p.ink,'right',600,w*.65);
            line(c,x,y+h*.48,x+w,y+h*.48,p.edge,2);line(c,x,y+h*.48,x+w*.74,y+h*.48,'#6abb9d',2);
            label(c,'74%',x,y+h*.7,Math.min(h*.2,14),p.sub,'left');label(c,translated('carEstimateValue','Car estimate {value}',{value:formatReading('range_km',390,p)}),x+w,y+h*.7,Math.min(h*.16,11),p.sub,'right',500,w*.77);
        } else if (t==='nav') {
            label(c,'↱',x+w*.1,cy,Math.min(w*.17,h*.76),p.accent);label(c,p.units && p.units.distance==='mi'?'262 yd':'240 m',x+w*.24,y+h*.4,Math.min(h*.36,30),p.ink,'left',650,w*.75);
            label(c,'Market Street',x+w*.24,y+h*.73,Math.min(h*.22,18),p.sub,'left',500,w*.75);
        } else if (t==='trip'||t==='tyres') {
            const rows=t==='tyres' ? ['tyre_fl','tyre_fr','tyre_rl','tyre_rr'].map(key=>[signals[key].label,formatReading(key,signals[key].sample,p)]) :
                [[translated('lastTrip','Last trip'),formatReading('trip_km',17.2,p)],[translated('tripTimeCaption','Time'),formatReading('trip_minutes',29,p)],[translated('cost','Cost'),formatReading('trip_cost',27.45,p)],[translated('average','Average'),formatReading('speed',37,p)]];
            if (t==='trip' && h>110*p.scale) rows.push([signals.trip_kwh.label,formatReading('trip_kwh',4.3,p)]);
            if (t==='trip' && h<135*p.scale && w>180*p.scale) {
                const columns=w/h>3.7 ? rows.length : Math.min(3,rows.length), rowH=h/Math.ceil(rows.length/columns);
                const gap=8*p.scale, cell=(w-(columns-1)*gap)/columns;
                rows.forEach(([title,value],i)=>{
                    const left=x+(i%columns)*(cell+gap), top=y+Math.floor(i/columns)*rowH;
                    const labelSize=Math.min(19*p.scale,rowH*.26,cell*.2), valueSize=Math.min(31*p.scale,rowH*.4,cell*.28);
                    label(c,title,left,top+rowH*.41-labelSize*.34,labelSize,p.sub,'left',500,cell);
                    label(c,value,left,top+rowH*.83-valueSize*.34,valueSize,p.ink,'left',600,cell);
                });
            } else {
                const size=Math.min(w*.092,h/(rows.length+.5)*.85,27*p.scale), lh=Math.min(h/rows.length,size*1.43), top=y+(h-lh*rows.length)/2;
                rows.forEach((row,i)=>{const rowY=top+(i+.5)*lh;label(c,row[0],x,rowY,size,p.sub,'left',500,w*.45);label(c,row[1],x+w,rowY,size,p.ink,'right',600,w*.55);});
            }
        }
        c.restore();
    }
    // Retained instruments live behind the author's layers, like their native counterparts.
    function baseInstruments(c,tpl,p,panel,width) {
        const compact=panel===480, factor=width/1920;
        c.save();c.scale(factor,factor);
        function mapDisc(cx,cy,r) {
            c.save();c.beginPath();c.arc(cx,cy,r,0,Math.PI*2);c.clip();
            rect(c,cx-r,cy-r,r*2,r*2,p.dark?'#233237':'#dae2da');
            c.strokeStyle=p.dark?'#435956':'#c1cec4';c.lineWidth=r*.035;
            for(let i=-4;i<=4;i++){
                line(c,cx+i*r*.4,cy-r,cx+(i-.55)*r*.4,cy+r,p.dark?'#405754':'#bac9c0',r*.04);
                line(c,cx-r,cy+i*r*.38,cx+r,cy+(i+.3)*r*.38,p.dark?'#405754':'#bac9c0',r*.04);
            }
            c.strokeStyle='#65bea9';c.lineWidth=r*.075;c.beginPath();c.moveTo(cx-r*.76,cy+r);c.lineTo(cx+r*.08,cy+r*.22);c.lineTo(cx+r*.2,cy-r*.32);c.lineTo(cx+r*.7,cy-r);c.stroke();
            disc(c,cx+r*.08,cy+r*.22,r*.075,'#6cc5ae');c.restore();arc(c,cx,cy,r,0,Math.PI*2,p.edge,2);
        }
        if(tpl==='nightwater')mapDisc(...(compact?[341,219,106]:[353,311,141]));
        if(tpl==='miler')mapDisc(...(compact?[236,273,91]:[260,438,130]));
        if(tpl==='ion-trio')mapDisc(...(compact?[1590,244,142]:[1610,380,214]));
        if(tpl==='yawline'||tpl==='cutline'){
            const box=tpl==='yawline'?(compact?[1533,100,318,256]:[1510,169,342,353]):(compact?[62,94,275,133]:[65,157,286,171]);
            const [x,y,w,h]=box,r=Math.min(w*.29,h*.31),cx=x+w/2,cy=y+h*.45;
            label(c,translated('gForce','G-force'),cx,y+h*.095,Math.min(26,h*.125),p.sub);arc(c,cx,cy,r,0,2*Math.PI,p.edge,2);arc(c,cx,cy,r*.55,0,2*Math.PI,p.edge,1);
            line(c,cx-r,cy,cx+r,cy,p.edge,1);line(c,cx,cy-r,cx,cy+r,p.edge,1);disc(c,cx+r*.1,cy-r*.15,4,p.accent);
            label(c,translated('lateralValue','Lateral   {value}',{value:'0.10 g'}),x+w*.26,y+h*.9,Math.min(h*.084,16),p.sub);label(c,translated('longitudinalValue','Long.   {value}',{value:'0.15 g'}),x+w*.76,y+h*.9,Math.min(h*.084,16),p.sub);
        }
        if(tpl==='navy-quadrant'){
            for(const side of [-1,1])for(let j=0;j<2;j++){
                const x=960+side*(compact?771:790), y=panel*(.36+j*.31), r=compact?52:70;
                arc(c,x,y,r,2.5,6.93,p.edge,2);arc(c,x,y,r,2.5,j?4.78:5.67,p.accent,4);
                label(c,(side<0?['74%','21°']:['4.3 kWh','0 kW'])[j],x,y+r*.2,r*.32,p.sub);
            }
        }
        if(tpl==='flux-ledger'){
            for(const side of [-1,1])for(let i=0;i<21;i++){
                const x=960+side*(compact?837:851),y=panel*(.25+i*.023);
                rect(c,x-12,y,24,panel*.012,(side<0?i>14:i>19)?p.accent:p.edge);
            }
        }
        c.restore();
    }
    function preview(canvas, recipe, options) {
        if (!canvas || !valid(recipe))
            return;
        const width = options.width || 1200, height = Math.round(width * options.panel / 1920);
        if (canvas.width !== width)
            canvas.width = width;
        if (canvas.height !== height)
            canvas.height = height;
        const dark = options.theme !== 'light', tpl = recipe.template;
        const parked = options.scenario === 'idle';
        const speed = Number.isFinite(options.speed) ? options.speed : parked ? 0 : 72;
        const power = Number.isFinite(options.power) ? options.power : parked ? 0 : 34;
        const p = { dark, speed, power, scale: width/1920, units:options.units, labels:options.labels,
            missing:options.scenario==='missing', readings:options.readings, currency:options.currency === undefined ? 'INR' : options.currency,
            gear: parked ? 'P' : 'D', separateGear: recipe.widgets.some(w=>w.type==='gear'), accent: colours[recipe.accent] || templates[tpl][3], ink: dark ? '#f1f5f5' : '#15262e', sub: dark ? '#c4cfd3' : '#38505b', face: dark ? 'rgba(19,33,42,.88)' : 'rgba(229,238,239,.91)', edge: dark ? '#455967' : '#9caeb7' };
        const c = canvas.getContext('2d'), g = c.createLinearGradient(0, 0, 0, height);
        const background = recipe.background || 'template', original = background === 'template';
        const stage = background === 'road' || original && ['motorcourt','yawline','miler','crosscheck','laneform','cutline'].includes(tpl);
        g.addColorStop(0, dark ? (stage ? '#17222e' : original && tpl==='navy-quadrant'?'#192b3c':'#1c2622') : stage?'#dce5e9':'#fafcfa');
        g.addColorStop(1, dark ? stage?'#0b1117':'#070e0b' : stage?'#b4c2ca':'#edf1ef');
        rect(c, 0, 0, width, height, g);
        if (background === 'aurora' || original && tpl === 'nightwater') {
            const a = load('aurora-' + (dark ? 'night' : 'day'));
            if (a)
                c.drawImage(a, 0, 0, width, height);
        }
        if (stage) scene(c, width, height, dark, original ? tpl : 'laneform');
        baseInstruments(c,tpl,p,options.panel,width);
        const a = area(recipe), sx = width * a.x, sy = height * a.y, sw = width * a.w, sh = height * a.h;
        const speedBox = recipe.widgets.find(a => a.type === 'speed');
        const withAlert=options.scenario==='left-alert' || options.scenario==='right-alert';
        const side = withAlert ? options.scenario.split('-')[0] : options.scenario==='left' || options.scenario==='right' ? options.scenario : null;
        const camera=side && cameraFrame(recipe,options.panel,side), sf=width/1920;
        const occupied=camera && {x:(camera[0]*sf-sx)/sw*1000,y:(camera[1]*sf-sy)/sh*1000,w:camera[2]*sf/sw*1000,h:camera[3]*sf/sh*1000};
        const pieces=cameraHud(options.panel,camera,!!(recipe.cameras && recipe.cameras[side]),withAlert);
        const shiftX=key=>(pieces.placed[key].x-pieces.home[key].x)*sf, shiftY=key=>(pieces.placed[key].y-pieces.home[key].y)*sf;
        function paint(a) {
            if (parked && (a.type === 'music' || a.type === 'nav') || occupied && overlap(a,occupied)) return;
            instrument(c, { type: a.type, signal:a.signal, x: sx + sw * a.x / 1000, y: sy + sh * a.y / 1000, w: sw * a.w / 1000, h: sh * a.h / 1000 }, tpl, p);
        }
        stack(recipe.widgets).forEach(paint);
        if (camera) {
            cameraPreview(c,camera,side,sf,dark);
            if (withAlert) {
                const r=pieces.placed.alert;
                rect(c,r.x*sf,r.y*sf,r.w*sf,r.h*sf,dark?'#492b24':'#f2d7ce');
                label(c,translated('doorOpen','Door open'),(r.x+r.w/2)*sf,(r.y+r.h*.50)*sf,r.h*.37*sf,dark?'#f3c4b6':'#722b19','center',650,r.w*.9*sf);
            }
            const alertBox=pieces.placed.alert;
            const overAlert=withAlert && overlap({x:sx+sw*speedBox.x/1000,y:sy+sh*speedBox.y/1000,w:sw*speedBox.w/1000,h:sh*speedBox.h/1000},{x:alertBox.x*sf,y:alertBox.y*sf,w:alertBox.w*sf,h:alertBox.h*sf});
            if (overlap(speedBox,occupied) || overAlert) {
                const b=pieces.placed.speed;
                rect(c,b.x*sf,b.y*sf,b.w*sf,b.h*sf,dark?'#182229':'#e6eeee');
                label(c,formatReading('speed',speed,p),(b.x+b.w/2)*sf,(b.y+b.h*.5)*sf,b.h*.55*sf,p.ink,'center',700);
            }
        }
        else if (options.scenario === 'hazard') {
            const scale = width / 1920, compact = options.panel === 480;
            const xx = (compact?386:100)*scale, yy = (compact?24:6)*scale, ww = (compact?256:336)*scale, hh = 44*scale;
            rect(c,xx,yy,ww,hh,dark?'#4c3526':'#f3d1a2');label(c,translated('potholeDistance','Pothole · {distance}',{distance:p.units && p.units.distance==='mi'?'85 yd':'80 m'}),xx+ww/2,yy+hh*.53,hh*.53,dark?'#fff0d9':'#533116','center',650);
            const hazard = {x:(xx-sx)/sw*1000,y:(yy-sy)/sh*1000,w:ww/sw*1000,h:hh/sh*1000};
            const digits = {x:speedBox.x+speedBox.w*.22,y:speedBox.y+speedBox.h*.25,w:speedBox.w*.56,h:speedBox.h*.5};
            if(recipe.space==='panel'&&overlap(digits,hazard)) label(c,formatReading('speed',speed,p),width*.5,height*.105,height*.082,p.ink,'center',700);
        }
        const compact=options.panel===480;
        label(c,'⬅',(compact?69:123)*sf+shiftX('left'),(compact?47:83)*sf+shiftY('left'),40*sf,p.edge);
        label(c,'➡',(compact?1851:1797)*sf+shiftX('right'),(compact?47:83)*sf+shiftY('right'),40*sf,p.edge);
        const rx=(compact?1472:1399)*sf+shiftX('right'), ry=(compact?47:83)*sf+shiftY('right');
        c.strokeStyle=dark?'#68be92':'#427960';c.lineWidth=1.3*sf;c.strokeRect(rx-15*sf,ry-10*sf,30*sf,20*sf);label(c,'OK',rx,ry,14*sf,dark?'#8dddb5':'#286e47','center',650);
        if(!recipe.widgets.some(w=>w.type==='gear' && !(occupied && overlap(w,occupied))))label(c,'P   R   N   D',width*.5+shiftX('gear'),(compact?451:686)*sf+shiftY('gear'),(compact?22:25)*sf,p.sub);
        if(!parked)label(c,'⌁  88  ▪▪▪',width*.373+shiftX('acc'),(compact?447:675)*sf+shiftY('acc'),18*sf,p.sub);

    }
    window.DashboardDesign = { templates, accents, colours, kinds, faces, signals, backgrounds, area, stack,
        minimum, fullCanvas, initial, valid, geometry, overlap, addSlot, upgrade, cameraGeometry, cameraFrame, cameraHud, editableCamera, formatReading, preview };
})();
