let mcount = ""
url = "hhttps://cbxjyqmooiccsu72vj52lwklce0sfwwp.lambda-url.us-east-1.on.aws/"
fetch(url)
  .then(response => response.text())
  .then((response) => {
      mcount = response
      for (let i = 0; i < mcount.length; i++) {
        var newSpan = document.createElement('span');
        newSpan.innerHTML = mcount[i];
        document.getElementById('mydiv').appendChild(newSpan);
      }
  })
  .catch(err => console.log(err))