function copyCode(btn){const pre=btn.parentElement.querySelector('code');if(!pre)return;const text=pre.innerText;navigator.clipboard.writeText(text).then(()=>{btn.innerText='Copied';btn.classList.add('accent');setTimeout(()=>{btn.innerText='Copy';btn.classList.remove('accent')},1500)})}
function setLang(lang){try{localStorage.setItem('lang',lang)}catch(e){}window.location.href=lang==='fa'?'./fa/':'./en/'}
function detect(){const saved=localStorage.getItem('lang');if(saved){window.location.href=saved==='fa'?'./fa/':'./en/';return}const hint=(navigator.language||navigator.userLanguage||'en').toLowerCase();if(hint.startsWith('fa')){window.location.href='./fa/'}else{window.location.href='./en/'}}
document.addEventListener('DOMContentLoaded',()=>{const redirector=document.body.dataset.redirector;if(redirector==='true'){detect()}})

