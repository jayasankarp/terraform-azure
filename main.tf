provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "example" {
    name     = "example-resource-group"
    location = "eastus"
}

resource "azurerm_virtual_network" "example" {
    name                = "example-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
    name                 = "example-subnet"
    resource_group_name  = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "example" {
    name                = "example-nic"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    ip_configuration {
        name                          = "example-config"
        subnet_id                     = azurerm_subnet.example.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_windows_virtual_machine" "example" {
    name                  = "example-vm"
    location              = azurerm_resource_group.example.location
    resource_group_name   = azurerm_resource_group.example.name
    network_interface_ids = [azurerm_network_interface.example.id]

    size                 = "Standard_B2s"
    admin_username       = "adminuser"
    admin_password       = "Password1234!"
    computer_name        = "examplevm"
    enable_automatic_updates = true

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }

    os_disk {
        name              = "example-osdisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    boot_diagnostics {
        storage_account_uri = "examplestorageaccount.blob.core.windows.net"
    }
}
