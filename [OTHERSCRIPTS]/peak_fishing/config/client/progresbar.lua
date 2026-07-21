return {
    progressBars = {
        rodUpgrade = {
            duration = 0,
            label = 'Upgrading your fishing rod...',
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped',
                flag = 1
            },
        },
        
        placeNet = {
            duration = 3000,
            label = 'Placing fishing net...',
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false
            },
            anim = {
                dict = 'missexile3',
                clip = 'ex03_dingy_search_case_a_michael',
                flag = 1
            },
        },
        
        removeNet = {
            duration = 3000,
            label = 'Removing fishing net...',
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false
            },
            anim = {
                dict = 'missexile3',
                clip = 'ex03_dingy_search_case_a_michael',
                flag = 1
            },
        }
    }
}