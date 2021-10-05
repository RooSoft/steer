const resetAttempts = () => {
  window.attempts = {needsMore: false}
}

resetAttempts()

const maybeRequestMoreAttempts = hook => {
  if(window.attempts.needsMore){
      let htlcId = window.attempts.lastAttemptHtlcId
      resetAttempts()

      hook.pushEvent("load-more", {"htlc-id": htlcId})
  }
}

const LoadMoreAttemptsHook = {
  mounted() {
      const loadMoreHook = this;
      
      this.el.addEventListener('load-more', function (e) { 
          maybeRequestMoreAttempts(loadMoreHook)
      }, false);

      maybeRequestMoreAttempts(loadMoreHook)
  }
}

export { LoadMoreAttemptsHook }