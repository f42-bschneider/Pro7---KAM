.spinnerOverlay {
  content: '';
  display: block;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: grey;
  opacity: 0.8;
}

.spinner{
  width: 60px;
  height: 60px;
  left: 50%;
  top:20%;
  margin-left:-30px;

  position: fixed;
  background-color: black;

  border-radius: 100%;  
  -webkit-animation: sk-scaleout 0.7s infinite ease-in-out;
  animation: sk-scaleout 0.7s infinite ease-in-out;
}

@-webkit-keyframes sk-scaleout {
  0% { -webkit-transform: scale(0) }
  100% {
    -webkit-transform: scale(1.0);
    opacity: 0;
  }
}

@keyframes sk-scaleout {
  0% { 
    -webkit-transform: scale(0);
    transform: scale(0);
  } 100% {
    -webkit-transform: scale(1.0);
    transform: scale(1.0);
    opacity: 0;
  }
}