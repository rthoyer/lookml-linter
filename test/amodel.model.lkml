
        connection: "datawarehouse"
        
    include: "*.view.lkml"

    week_start_day: sunday
    week_start_day: monday

    explore: explore1 {
        from: view1
        join: view2 {
            from: view2
        }
    }
    