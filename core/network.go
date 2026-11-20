//go:build android && cgo

package main

import (
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/dns"
)

type networkResetter interface {
	ResetNetwork()
}

func resetOutbounds() {
	// Providers can expose the same outbound under different names; reset each adapter once.
	reset := make(map[networkResetter]struct{})
	forEachProxy(func(proxy constant.Proxy) {
		outbound, ok := proxy.Adapter().(networkResetter)
		if !ok {
			return
		}
		if _, done := reset[outbound]; done {
			return
		}
		reset[outbound] = struct{}{}
		outbound.ResetNetwork()
	})
}

func handleResetNetwork() {
	runLock.Lock()
	defer runLock.Unlock()
	if !isInit {
		return
	}
	closeConnections()
	resetOutbounds()
	dnsLock.Lock()
	dns.FlushCacheWithDefaultResolver()
	dnsLock.Unlock()
}
