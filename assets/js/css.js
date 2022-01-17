let my_css = {
  getNodeStatusColor: (is_lnd_node_online) => {
    switch(is_lnd_node_online) {
      case true:
        return 'bg-node-online';
      case false:
        return 'bg-node-offline';
      default:
        // undefined
        return '';
    }
  },

  getNodeStatusText: (is_lnd_node_online) => {
    switch(is_lnd_node_online) {
      case true:
        return 'online';
      case false:
        return 'offline';
      default:
        // undefined
        return 'unknown';
    }
  }
}

export default my_css