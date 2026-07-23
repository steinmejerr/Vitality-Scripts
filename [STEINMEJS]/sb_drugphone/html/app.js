const phone=document.getElementById('phone');
const homeView=document.getElementById('home-view');
const chatView=document.getElementById('chat-view');
const productsEl=document.getElementById('products');
const stopButton=document.getElementById('stop');
const statusLabel=document.getElementById('status-label');
const statusText=document.getElementById('status-text');
const messagesEl=document.getElementById('messages');
const summaryEl=document.getElementById('offer-summary');
const actionsEl=document.getElementById('actions');
let state={products:[],dealing:false,selectedProduct:null,offer:null};

const post=(name,data={})=>fetch(`https://${GetParentResourceName()}/${name}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)}).then(r=>r.json()).catch(()=>({}));
const money=n=>new Intl.NumberFormat('da-DK').format(n)+' kr.';
const iconMap={cannabis:'fa-solid fa-cannabis',snowflake:'fa-solid fa-snowflake',flask:'fa-solid fa-flask'};

function render(){
  stopButton.classList.toggle('hidden',!state.dealing);
  statusLabel.textContent=state.dealing?'Aktiv':'Offline';
  const selected=state.products.find(p=>p.id===state.selectedProduct);
  statusText.textContent=state.dealing?`Du sælger ${selected?.label||'produkt'}. Vent på en besked fra en køber.`:'Vælg et produkt for at begynde at modtage beskeder.';
  productsEl.innerHTML=state.products.map(p=>`<article class="product ${p.active?'active':''}" data-id="${p.id}"><div class="product-icon"><i class="${iconMap[p.icon]||'fa-solid fa-box'}"></i></div><div><h3>${p.label}</h3><p>Ordrer fra ${p.minAmount} til ${p.maxAmount} stk.</p></div><span class="product-action">${p.active?'AKTIV':'START'}</span></article>`).join('');
  productsEl.querySelectorAll('.product').forEach(card=>card.onclick=async()=>{await post('startDealing',{productId:card.dataset.id})});
  if(state.offer) showChat(); else showHome();
}

function showHome(){homeView.classList.remove('hidden');chatView.classList.add('hidden')}
function showChat(){
  homeView.classList.add('hidden');chatView.classList.remove('hidden');
  const o=state.offer;
  const rows=[`<div class="message in">${o.intro}</div>`,`<div class="message in">${o.message}</div>`];
  if(o.accepted){rows.push(`<div class="message out">${o.reply}</div>`,`<div class="message in">${o.locationMessage}</div>`)}
  messagesEl.innerHTML=rows.join('');
  summaryEl.innerHTML=`<div class="offer-row"><span>Produkt</span><strong>${o.productLabel}</strong></div><div class="offer-row"><span>Antal</span><strong>${o.amount}x</strong></div><div class="offer-row"><span>Pris pr. stk.</span><strong>${money(o.unitPrice)}</strong></div><div class="offer-row total"><span>Samlet betaling</span><strong>${money(o.total)}</strong></div>`;
  actionsEl.classList.toggle('hidden',!!o.accepted);
}

window.addEventListener('message',e=>{
  const {action,data}=e.data;
  if(action==='open') phone.classList.remove('hidden');
  if(action==='close') phone.classList.add('hidden');
  if(action==='sync'){state=data;render()}
});

document.getElementById('close').onclick=()=>post('close');
document.getElementById('back').onclick=showHome;
document.getElementById('stop').onclick=()=>post('stopDealing');
document.getElementById('reject').onclick=()=>post('rejectOffer');
document.getElementById('accept').onclick=()=>post('acceptOffer');
document.addEventListener('keyup',e=>{if(e.key==='Escape')post('close')});
