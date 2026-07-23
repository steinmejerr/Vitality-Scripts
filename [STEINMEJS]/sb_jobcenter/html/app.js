const app=document.getElementById('app');
const jobsEl=document.getElementById('jobs');
const categoriesEl=document.getElementById('categories');
const markersEl=document.getElementById('markers');
const searchEl=document.getElementById('search');
let state={jobs:[],selected:null,category:'Alle',search:'',currentJob:'unemployed'};

const post=(name,data={})=>fetch(`https://${GetParentResourceName()}/${name}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});

function renderCategories(){
  const cats=['Alle',...new Set(state.jobs.map(j=>j.category))];
  categoriesEl.innerHTML=cats.map(c=>`<button class="category ${state.category===c?'active':''}" data-cat="${c}">${c}</button>`).join('');
  categoriesEl.querySelectorAll('.category').forEach(b=>b.onclick=()=>{state.category=b.dataset.cat;renderCategories();renderJobs()});
}

function renderMarkers(){
  markersEl.innerHTML=state.jobs.map(j=>`<div class="marker ${state.selected?.id===j.id?'active':''}" style="left:${j.map.x}%;top:${j.map.y}%;${state.selected?.id===j.id?`background:${j.color}`:''}" title="${j.label}"><i class="${j.icon}"></i></div>`).join('');
}

function renderJobs(){
  const q=state.search.toLowerCase();
  const list=state.jobs.filter(j=>(state.category==='Alle'||j.category===state.category)&&(!q||j.label.toLowerCase().includes(q)||j.description.toLowerCase().includes(q)));
  jobsEl.innerHTML=list.map(j=>`<article class="job-card ${state.selected?.id===j.id?'active':''}" data-id="${j.id}"><div class="job-card-icon" style="color:${j.color};background:${j.color}18"><i class="${j.icon}"></i></div><div><h3>${j.label}</h3><p>${j.category} · ${j.salary}</p></div><i class="fa-solid fa-chevron-right"></i></article>`).join('')||'<p style="color:#92a098;font-size:13px">Ingen jobs fundet.</p>';
  jobsEl.querySelectorAll('.job-card').forEach(card=>card.onclick=()=>selectJob(card.dataset.id));
}

function selectJob(id){
  state.selected=state.jobs.find(j=>j.id===id);
  if(!state.selected)return;
  const j=state.selected;
  document.getElementById('empty-state').classList.add('hidden');
  document.getElementById('job-details').classList.remove('hidden');
  document.getElementById('waypoint').classList.remove('hidden');
  document.getElementById('map-title').textContent=j.label;
  document.getElementById('detail-title').textContent=j.label;
  document.getElementById('detail-category').textContent=j.category.toUpperCase();
  document.getElementById('detail-description').textContent=j.description;
  document.getElementById('detail-salary').textContent=j.salary;
  const icon=document.getElementById('detail-icon');
  icon.innerHTML=`<i class="${j.icon}"></i>`;icon.style.color=j.color;icon.style.background=`${j.color}18`;
  document.getElementById('requirements').innerHTML=j.requirements.map(r=>`<span class="requirement"><i class="fa-solid fa-check"></i>${r}</span>`).join('');
  const button=document.getElementById('select-job');
  button.textContent='';button.innerHTML=state.currentJob===j.job?'<i class="fa-solid fa-briefcase"></i>Du har allerede dette job':'<i class="fa-solid fa-check"></i>Vælg dette job';
  button.disabled=state.currentJob===j.job;
  button.style.opacity=button.disabled?'.55':'1';
  renderJobs();renderMarkers();
}

function open(data){
  state={jobs:data.jobs||[],selected:null,category:'Alle',search:'',currentJob:data.currentJob||'unemployed'};
  searchEl.value='';
  document.getElementById('empty-state').classList.remove('hidden');
  document.getElementById('job-details').classList.add('hidden');
  document.getElementById('waypoint').classList.add('hidden');
  document.getElementById('map-title').textContent='Vælg et job';
  app.classList.remove('hidden');renderCategories();renderJobs();renderMarkers();
}

function close(){app.classList.add('hidden');post('close')}
window.addEventListener('message',e=>{if(e.data.action==='open')open(e.data);if(e.data.action==='close')app.classList.add('hidden')});
document.getElementById('close').onclick=close;
searchEl.oninput=e=>{state.search=e.target.value;renderJobs()};
document.getElementById('waypoint').onclick=()=>state.selected&&post('setWaypoint',{id:state.selected.id});
document.getElementById('select-job').onclick=()=>state.selected&&state.currentJob!==state.selected.job&&post('selectJob',{id:state.selected.id});
document.addEventListener('keyup',e=>{if(e.key==='Escape')close()});
