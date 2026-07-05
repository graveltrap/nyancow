(function () {
  var CLIENT_ID = '1522159755546857492';
  var GUILD_ID = '347763631351660544';
  var INVITE = 'https://discord.gg/2HGQaUJrug';
  var TOKEN_KEY = 'nc_discord_token';
  var MEMBER_UNTIL_KEY = 'nc_member_until';
  var RETURN_KEY = 'nc_return_to';
  var SCOPE = 'identify guilds.members.read';

  function redirectUri() {
    return location.origin + '/auth/callback.html';
  }

  function sendToLogin() {
    sessionStorage.setItem(RETURN_KEY, location.pathname);
    var url = 'https://discord.com/api/oauth2/authorize'
      + '?client_id=' + encodeURIComponent(CLIENT_ID)
      + '&redirect_uri=' + encodeURIComponent(redirectUri())
      + '&response_type=token'
      + '&scope=' + encodeURIComponent(SCOPE);
    location.replace(url);
  }

  function sendToWelcome() {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(MEMBER_UNTIL_KEY);
    location.replace(INVITE);
  }

  function reveal() {
    document.documentElement.classList.remove('nc-gate-pending');
  }

  var cachedUntil = parseInt(localStorage.getItem(MEMBER_UNTIL_KEY) || '0', 10);
  if (Date.now() < cachedUntil) {
    reveal();
    return;
  }

  var token = localStorage.getItem(TOKEN_KEY);
  if (!token) {
    sendToLogin();
    return;
  }

  fetch('https://discord.com/api/users/@me/guilds/' + GUILD_ID + '/member', {
    headers: { Authorization: 'Bearer ' + token }
  }).then(function (res) {
    if (res.status === 200) {
      localStorage.setItem(MEMBER_UNTIL_KEY, String(Date.now() + 12 * 60 * 60 * 1000));
      reveal();
    } else {
      sendToWelcome();
    }
  }).catch(function () {
    sendToWelcome();
  });
})();
