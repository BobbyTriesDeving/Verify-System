RegisterNetEvent('verifysystem:notify', function(message)
    lib.notify({
        title = 'Verify System',
        description = message,
        type = 'success'
    })
end)
