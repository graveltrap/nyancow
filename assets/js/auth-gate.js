(function () {
  var CLIENT_ID = '1522159755546857492';
  var GUILD_ID = '347763631351660544';
  var INVITE = 'https://discord.gg/2HGQaUJrug';
  var TOKEN_KEY = 'nc_discord_token';
  var MEMBER_UNTIL_KEY = 'nc_member_until';
  var RETURN_KEY = 'nc_return_to';
  var LOGIN_TRIED_KEY = 'nc_login_tried';
  var SCOPE = 'identify guilds.members.read';

  function redirectUri() {
    return location.origin + '/auth/callback.html';
  }

  function sendToLogin() {
    // Loop guard: if we already round-tripped through OAuth this session and
    // still can't verify, fall through to the invite instead of bouncing forever.
    if (sessionStorage.getItem(LOGIN_TRIED_KEY)) {
      sendToWelcome();
      return;
    }
    sessionStorage.setItem(LOGIN_TRIED_KEY, '1');
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
    sessionStorage.removeItem(LOGIN_TRIED_KEY);
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
    } else if (res.status === 404) {
      // Valid token, definitively not in the guild.
      sendToWelcome();
    } else {
      // Expired/stale token, wrong scope, rate limit — anything ambiguous gets a fresh login.
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem(MEMBER_UNTIL_KEY);
      sendToLogin();
    }
  }).catch(function () {
    sendToLogin();
  });
})();
