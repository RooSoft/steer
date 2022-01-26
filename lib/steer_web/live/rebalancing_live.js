const RebalancingGenerateIgniterHook = {
  mounted() {
    const hook = this;

    this.el.addEventListener("rebalancing-generate-igniter", function (e) {
      hook.pushEvent("rebalancing-generate-igniter", e.detail)
    })
  }
}

export { RebalancingGenerateIgniterHook }