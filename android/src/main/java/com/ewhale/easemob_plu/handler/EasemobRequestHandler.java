package com.ewhale.easemob_plu.handler;

import io.flutter.plugin.common.PluginRegistry;

/**
 * @author Puppet
 */
public class EasemobRequestHandler {
    private static PluginRegistry.Registrar registrar = null;

    public static void setRegistrar(PluginRegistry.Registrar reg) {
        EasemobRequestHandler.registrar = reg;
    }

    public PluginRegistry.Registrar getRegistrar() {
        return registrar;
    }
}
