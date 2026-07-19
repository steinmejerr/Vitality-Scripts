const app=document.getElementById('app'),runsEl=document.getElementById('runs'),statusEl=document.getElementById('status'),cooldownLabel=document.getElementById('cooldownLabel');
let state=null,timer=null;
const post=(name,data={})=>fetch(`https://${GetParentResourceName()}/${name}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)}).then(r=>r.json());
const money=n=>new Intl.NumberFormat('da-DK').format(n);
function formatTime(sec){if(sec<=0)return 'Klar nu';const m=Math.ceil(sec/60);return `${m} min. tilbage`}
function render(){
 const blocked=state.cooldown>0||!!state.activeRun;
 statusEl.innerHTML=`<div class="status-card"><span>Status</span><strong>${state.activeRun?'Run i gang':state.cooldown>0?'På cooldown':'Klar til et run'}</strong></div><div class="status-card"><span>Cooldown</span><strong>${formatTime(state.cooldown)}</strong></div>`;
 cooldownLabel.textContent=`${state.cooldownMinutes} minutters cooldown`;
 runsEl.innerHTML=state.runs.map(run=>`<article class="card"><div class="card-icon"><i class="${run.icon}"></i></div><h3>${run.label}</h3><p>${run.description}</p><div class="reward"><small>Betaling i sorte penge</small>${money(run.rewardMin)} – ${money(run.rewardMax)} kr.</div><button class="primary" data-run="${run.id}" ${blocked?'disabled':''}>Start run</button></article>`).join('');
 document.querySelectorAll('[data-run]').forEach(btn=>btn.onclick=async()=>{btn.disabled=true;const res=await post('startRun',{id:btn.dataset.run});if(!res.success){btn.disabled=false;return}app.classList.add('hidden')});
}
window.addEventListener('message',e=>{if(e.data.action==='open'){state=e.data.data;app.classList.remove('hidden');render();clearInterval(timer);timer=setInterval(()=>{if(state&&state.cooldown>0){state.cooldown--;render()}},1000)}if(e.data.action==='close')app.classList.add('hidden')});
document.getElementById('close').onclick=()=>{app.classList.add('hidden');post('close')};
document.addEventListener('keyup',e=>{if(e.key==='Escape'){app.classList.add('hidden');post('close')}});
