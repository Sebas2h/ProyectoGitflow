(() => {
  const source = document.body.dataset.profileMusic;
  const gear = document.querySelector('.profile-settings-button');
  let standaloneAudio = null;

  if (source) {
    if (window.parent !== window && window.parent.dashboardControls?.setProfileMusic) {
      window.parent.dashboardControls.setProfileMusic(new URL(source, window.location.href).href);
    } else {
      standaloneAudio = new Audio(source);
      standaloneAudio.loop = true;
      standaloneAudio.volume = Number(localStorage.getItem('musicVolume') ?? .3);
      if (localStorage.getItem('musicEnabled') !== 'false') standaloneAudio.play().catch(() => {});
    }
  }

  gear?.addEventListener('click', () => {
    if (window.parent !== window && window.parent.dashboardControls?.openSettings) {
      window.parent.dashboardControls.openSettings();
      return;
    }
    const enabled = localStorage.getItem('musicEnabled') !== 'false';
    localStorage.setItem('musicEnabled', String(!enabled));
    if (!standaloneAudio || !source) return;
    if (enabled) standaloneAudio.pause(); else standaloneAudio.play().catch(() => {});
  });

  document.querySelector('.back-team')?.addEventListener('click', () => {
    standaloneAudio?.pause();
    window.parent.dashboardControls?.restoreBaseMusic?.();
  });
})();
