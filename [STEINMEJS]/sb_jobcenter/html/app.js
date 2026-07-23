const app=document.getElementById('app');
const jobsEl=document.getElementById('jobs');
const categoriesEl=document.getElementById('categories');
const markersEl=document.getElementById('markers');
const searchEl=document.getElementById('search');
const mapViewport=document.getElementById('interactive-map');
const mapCanvas=document.getElementById('map-canvas');
let state={jobs:[],selected:null,category:'Alle',search:'',currentJob:'unemployed'};
let mapState={scale:1,x:0,y:0,dragging:false,moved:false,pointerId:null,startX:0,startY:0,originX:0,originY:0,minScale:1,maxScale:4};

const post=(name,data={})=>fetch(`https://${GetParentResourceName()}/${name}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});

function renderCategories(){
  const cats=['Alle',...new Set(state.jobs.map(j=>j.category))];
  categoriesEl.innerHTML=cats.map(c=>`<button class="category ${state.category===c?'active':''}" data-cat="${c}">${c}</button>`).join('');
  categoriesEl.querySelectorAll('.category').forEach(b=>b.onclick=()=>{state.category=b.dataset.cat;renderCategories();renderJobs()});
}

function renderMarkers(){
  markersEl.innerHTML=state.jobs.map(j=>`<button class="marker ${state.selected?.id===j.id?'active':''}" data-id="${j.id}" style="left:${j.map.x}%;top:${j.map.y}%;${state.selected?.id===j.id?`background:${j.color}`:''}" title="${j.label}"><i class="${j.icon}"></i><span>${j.label}</span></button>`).join('');
  markersEl.querySelectorAll('.marker').forEach(marker=>{
    marker.addEventListener('pointerdown',e=>e.stopPropagation());
    marker.addEventListener('click',e=>{e.stopPropagation();selectJob(marker.dataset.id,true)});
  });
  updateMarkerScale();
}

function renderJobs(){
  const q=state.search.toLowerCase();
  const list=state.jobs.filter(j=>(state.category==='Alle'||j.category===state.category)&&(!q||j.label.toLowerCase().includes(q)||j.description.toLowerCase().includes(q)));
  jobsEl.innerHTML=list.map(j=>`<article class="job-card ${state.selected?.id===j.id?'active':''}" data-id="${j.id}"><div class="job-card-icon" style="color:${j.color};background:${j.color}18"><i class="${j.icon}"></i></div><div><h3>${j.label}</h3><p>${j.category} · ${j.salary}</p></div><i class="fa-solid fa-chevron-right"></i></article>`).join('')||'<p style="color:#92a098;font-size:13px">Ingen jobs fundet.</p>';
  jobsEl.querySelectorAll('.job-card').forEach(card=>card.onclick=()=>selectJob(card.dataset.id));
}

function selectJob(id,focusMap=false){
  state.selected=state.jobs.find(j=>j.id===id);
  if(!state.selected)return;
  const j=state.selected;
  document.getElementById('empty-state').classList.add('hidden');
  document.getElementById('job-details').classList.remove('hidden');
  document.getElementById('map-actions').classList.remove('hidden');
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
  if(focusMap) focusSelectedJob();
}

function clamp(value,min,max){return Math.min(max,Math.max(min,value))}

function updateMapMinScale(){
  const viewport=mapViewport.getBoundingClientRect();
  const baseWidth=mapCanvas.offsetWidth || viewport.width;
  const baseHeight=mapCanvas.offsetHeight || viewport.height;
  const minScaleX=viewport.width / baseWidth;
  const minScaleY=viewport.height / baseHeight;
  mapState.minScale=Math.max(1, minScaleX, minScaleY);
  if(mapState.scale < mapState.minScale) mapState.scale = mapState.minScale;
}

function updateMarkerScale(){
  // Markørerne bliver gradvist mindre på skærmen, jo længere der zoomes ind.
  const markerScale=Math.pow(mapState.scale,-1.35);
  markersEl.style.setProperty('--marker-scale',markerScale.toFixed(4));
}

function applyMapTransform(animated=false){
  mapCanvas.classList.toggle('animated',animated);
  mapCanvas.style.transform=`translate(calc(-50% + ${mapState.x}px),calc(-50% + ${mapState.y}px)) scale(${mapState.scale})`;
  updateMarkerScale();
  if(animated)setTimeout(()=>mapCanvas.classList.remove('animated'),280);
}

function getMapBounds(){
  const viewport=mapViewport.getBoundingClientRect();
  const canvasWidth=mapCanvas.offsetWidth*mapState.scale;
  const canvasHeight=mapCanvas.offsetHeight*mapState.scale;
  return {
    x:Math.max(0,(canvasWidth-viewport.width)/2),
    y:Math.max(0,(canvasHeight-viewport.height)/2)
  };
}

function clampMapPosition(){
  const bounds=getMapBounds();
  mapState.x=clamp(mapState.x,-bounds.x,bounds.x);
  mapState.y=clamp(mapState.y,-bounds.y,bounds.y);
}
function resetMap(animated=false){
  updateMapMinScale();
  mapState.scale=mapState.minScale;mapState.x=0;mapState.y=0;
  applyMapTransform(animated);
}

function setMapZoom(nextScale,clientX,clientY){
  updateMapMinScale();
  const previous=mapState.scale;
  const scale=clamp(nextScale,mapState.minScale,mapState.maxScale);
  if(scale===previous)return;
  const rect=mapViewport.getBoundingClientRect();
  const px=(clientX??(rect.left+rect.width/2))-(rect.left+rect.width/2);
  const py=(clientY??(rect.top+rect.height/2))-(rect.top+rect.height/2);
  const ratio=scale/previous;
  mapState.x=px-(px-mapState.x)*ratio;
  mapState.y=py-(py-mapState.y)*ratio;
  mapState.scale=scale;
  clampMapPosition();applyMapTransform();
}

function focusSelectedJob(){
  if(!state.selected)return;
  updateMapMinScale();
  mapState.scale=Math.max(1.7, mapState.minScale);
  const canvasWidth=mapCanvas.offsetWidth*mapState.scale;
  const canvasHeight=mapCanvas.offsetHeight*mapState.scale;
  mapState.x=(50-state.selected.map.x)/100*canvasWidth;
  mapState.y=(50-state.selected.map.y)/100*canvasHeight;
  clampMapPosition();applyMapTransform(true);
}

mapViewport.addEventListener('wheel',e=>{
  e.preventDefault();
  setMapZoom(mapState.scale+(e.deltaY<0?.22:-.22),e.clientX,e.clientY);
},{passive:false});

mapViewport.addEventListener('pointerdown',e=>{
  if(e.button!==0)return;
  mapState.dragging=true;mapState.moved=false;mapState.pointerId=e.pointerId;
  mapState.startX=e.clientX;mapState.startY=e.clientY;
  mapState.originX=mapState.x;mapState.originY=mapState.y;
  mapViewport.setPointerCapture(e.pointerId);
  mapViewport.classList.add('dragging');
});
mapViewport.addEventListener('pointermove',e=>{
  if(!mapState.dragging||e.pointerId!==mapState.pointerId)return;
  const dx=e.clientX-mapState.startX;const dy=e.clientY-mapState.startY;
  if(Math.abs(dx)>2||Math.abs(dy)>2)mapState.moved=true;
  mapState.x=mapState.originX+dx;
  mapState.y=mapState.originY+dy;
  clampMapPosition();applyMapTransform();
});
function endMapDrag(e){
  if(e.pointerId!==mapState.pointerId)return;
  mapState.dragging=false;mapState.pointerId=null;
  mapViewport.classList.remove('dragging');
  try{mapViewport.releasePointerCapture(e.pointerId)}catch(_){ }
}
mapViewport.addEventListener('pointerup',endMapDrag);
mapViewport.addEventListener('pointercancel',endMapDrag);
document.getElementById('map-zoom-in').onclick=e=>{e.stopPropagation();setMapZoom(mapState.scale+.3)};
document.getElementById('map-zoom-out').onclick=e=>{e.stopPropagation();setMapZoom(mapState.scale-.3)};
document.getElementById('map-reset').onclick=e=>{e.stopPropagation();resetMap(true)};
window.addEventListener('resize',()=>{updateMapMinScale();clampMapPosition();applyMapTransform()});

function open(data){
  state={jobs:data.jobs||[],selected:null,category:'Alle',search:'',currentJob:data.currentJob||'unemployed'};
  searchEl.value='';
  document.getElementById('empty-state').classList.remove('hidden');
  document.getElementById('job-details').classList.add('hidden');
  document.getElementById('map-actions').classList.add('hidden');
  document.getElementById('map-title').textContent='Vælg et job';
  app.classList.remove('hidden');resetMap();renderCategories();renderJobs();renderMarkers();
}

function close(){app.classList.add('hidden');post('close')}
window.addEventListener('message',e=>{if(e.data.action==='open')open(e.data);if(e.data.action==='close')app.classList.add('hidden');if(e.data.action==='previewJob'&&e.data.id)selectJob(e.data.id,true)});
document.getElementById('close').onclick=close;
searchEl.oninput=e=>{state.search=e.target.value;renderJobs()};
document.getElementById('waypoint').onclick=()=>state.selected&&post('setWaypoint',{id:state.selected.id});
document.getElementById('select-job').onclick=()=>state.selected&&state.currentJob!==state.selected.job&&post('selectJob',{id:state.selected.id});
document.addEventListener('keyup',e=>{if(e.key==='Escape')close()});
