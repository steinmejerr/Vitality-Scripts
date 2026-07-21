const app=document.getElementById('app'),shopView=document.getElementById('shop-view'),craftView=document.getElementById('craft-view'),modal=document.getElementById('modal'),placementHelp=document.getElementById('placement-help');
const previewStage=document.getElementById('preview-stage'),previewObject=document.getElementById('preview-object');
const previewFrontIcon=document.getElementById('preview-front-icon'),previewBackIcon=document.getElementById('preview-back-icon');
const previewFrontLabel=document.getElementById('preview-front-label'),previewOutput=document.getElementById('preview-output');
const previewCategory=document.getElementById('preview-category'),previewTopLabel=document.getElementById('preview-top-label');

let state={recipes:[],categories:{},inventory:{},category:'all',search:'',selected:null,amount:1};
let previewRotation={x:-18,y:28},previewDragging=false,previewPointerId=null,previewStart={x:0,y:0,rotX:0,rotY:0};

const post=(name,data={})=>fetch(`https://${GetParentResourceName()}/${name}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});
const money=n=>new Intl.NumberFormat('da-DK').format(n)+' kr.';

function close(){app.classList.add('hidden');modal.classList.add('hidden');post('close')}
function openBase(title,subtitle){document.getElementById('title').textContent=title;document.getElementById('subtitle').textContent=subtitle;app.classList.remove('hidden')}

function renderCategories(){const el=document.getElementById('categories');el.innerHTML='';const all=document.createElement('button');all.className=`category ${state.category==='all'?'active':''}`;all.innerHTML='<i class="fa-solid fa-border-all"></i><span>Alle opskrifter</span>';all.onclick=()=>{state.category='all';renderCategories();renderRecipes()};el.appendChild(all);Object.entries(state.categories).forEach(([id,c])=>{const b=document.createElement('button');b.className=`category ${state.category===id?'active':''}`;b.innerHTML=`<i class="${c.icon||'fa-solid fa-box'}"></i><span>${c.label}</span>`;b.onclick=()=>{state.category=id;renderCategories();renderRecipes()};el.appendChild(b)})}

function renderRecipes(){const el=document.getElementById('recipes');const q=state.search.toLowerCase();const list=state.recipes.filter(r=>(state.category==='all'||r.category===state.category)&&(!q||r.label.toLowerCase().includes(q)||r.description.toLowerCase().includes(q)));document.getElementById('category-title').textContent=state.category==='all'?'Alle opskrifter':state.categories[state.category]?.label||'Opskrifter';el.innerHTML=list.map(r=>`<article class="recipe-card" data-id="${r.id}"><div class="recipe-icon"><i class="${r.icon||'fa-solid fa-hammer'}"></i></div><h3>${r.label}</h3><p>${r.description}</p><span class="recipe-output">${r.output.count}x resultat</span></article>`).join('')||'<p style="color:#94a19a">Ingen opskrifter fundet.</p>';el.querySelectorAll('.recipe-card').forEach(card=>card.onclick=()=>openRecipe(card.dataset.id))}

function updatePreviewTransform(){previewObject.style.transform=`translate(-50%,-50%) rotateX(${previewRotation.x}deg) rotateY(${previewRotation.y}deg)`}
function resetPreviewRotation(){previewRotation={x:-18,y:28};updatePreviewTransform()}
function updatePreview(recipe){if(!recipe) return;const icon=recipe.icon||'fa-solid fa-hammer';const category=state.categories[recipe.category]?.label||'Crafting';previewFrontIcon.className=icon;previewBackIcon.className=icon;previewFrontLabel.textContent=recipe.label;previewOutput.textContent=`${recipe.output.count}x`;previewCategory.textContent=category;previewTopLabel.textContent=recipe.label}

function openRecipe(id){state.selected=state.recipes.find(r=>r.id===id);state.amount=1;if(!state.selected)return;document.getElementById('modal-title').textContent=state.selected.label;document.getElementById('modal-description').textContent=state.selected.description;document.getElementById('modal-icon').innerHTML=`<i class="${state.selected.icon||'fa-solid fa-hammer'}"></i>`;updatePreview(state.selected);resetPreviewRotation();renderModal();modal.classList.remove('hidden')}

function renderModal(){document.getElementById('amount').textContent=state.amount;document.getElementById('ingredients').innerHTML=state.selected.ingredients.map(i=>{const need=i.count*state.amount,have=state.inventory[i.item]||0;return `<div class="ingredient ${have>=need?'enough':'missing'}"><span>${i.label||i.item}<br><small>Du har ${have}</small></span><strong>${need}x</strong></div>`}).join('')}

function startPreviewDrag(e){previewDragging=true;previewPointerId=e.pointerId;previewStage.setPointerCapture(e.pointerId);previewStart={x:e.clientX,y:e.clientY,rotX:previewRotation.x,rotY:previewRotation.y};}
function movePreviewDrag(e){if(!previewDragging||e.pointerId!==previewPointerId) return;const deltaX=e.clientX-previewStart.x;const deltaY=e.clientY-previewStart.y;previewRotation.y=previewStart.rotY+(deltaX*0.45);previewRotation.x=Math.max(-50,Math.min(35,previewStart.rotX-(deltaY*0.35)));updatePreviewTransform()}
function endPreviewDrag(e){if(e.pointerId!==previewPointerId) return;previewDragging=false;previewPointerId=null;try{previewStage.releasePointerCapture(e.pointerId)}catch(err){}}

previewStage.addEventListener('pointerdown',startPreviewDrag);
previewStage.addEventListener('pointermove',movePreviewDrag);
previewStage.addEventListener('pointerup',endPreviewDrag);
previewStage.addEventListener('pointercancel',endPreviewDrag);
previewStage.addEventListener('mouseleave',()=>{previewDragging=false;previewPointerId=null});

window.addEventListener('message',e=>{const {action,data}=e.data;if(action==='openShop'){openBase('Crafting-forhandler','Køb en station og placér den, hvor du vil.');craftView.classList.add('hidden');shopView.classList.remove('hidden');document.getElementById('shop-price').textContent=money(data.price)}if(action==='openCrafting'){state={...state,...data,category:'all',search:'',selected:null,amount:1};openBase('Crafting Station','Vælg en opskrift og lav dit udstyr.');shopView.classList.add('hidden');craftView.classList.remove('hidden');renderCategories();renderRecipes()}if(action==='showPlacementHelp'){placementHelp.classList.remove('hidden')}if(action==='hidePlacementHelp'){placementHelp.classList.add('hidden')}if(action==='close'){app.classList.add('hidden');modal.classList.add('hidden')}});

document.getElementById('close').onclick=close;document.getElementById('buy-station').onclick=()=>post('buyStation');document.getElementById('search').oninput=e=>{state.search=e.target.value;renderRecipes()};document.getElementById('modal-close').onclick=()=>modal.classList.add('hidden');document.getElementById('minus').onclick=()=>{state.amount=Math.max(1,state.amount-1);renderModal()};document.getElementById('plus').onclick=()=>{state.amount=Math.min(100,state.amount+1);renderModal()};document.getElementById('craft-button').onclick=()=>{if(state.selected)post('craft',{recipeId:state.selected.id,amount:state.amount})};document.addEventListener('keyup',e=>{if(e.key==='Escape'){if(!modal.classList.contains('hidden'))modal.classList.add('hidden');else close()}});
