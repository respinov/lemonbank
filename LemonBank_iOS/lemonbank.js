btnMoreInfo.onclick = function() {
	document.getElementById('main-content2').style.display = 'inline-block';
	document.getElementById('main-content').style.display = 'none';
	document.getElementById('btnMoreInfo').style.display = 'none';
	document.getElementById('btnLessInfo').style.display = 'inline-block';
}

btnLessInfo.onclick = function() {
	document.getElementById('main-content2').style.display = 'none';
	document.getElementById('main-content').style.display = 'inline-block';
	document.getElementById('btnMoreInfo').style.display = 'inline-block';
	document.getElementById('btnLessInfo').style.display = 'none';
}