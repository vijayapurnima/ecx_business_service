class EcxBusinessService::Stats::Kpis
    include Interactor
  
    def call
      context[:kpis] = {
        business: {
          total: EcxBusinessService::Profile::Organisation.count,
          last_week: EcxBusinessService::Profile::Organisation.where("created_at >= ?", 1.week.ago.beginning_of_day).count
        }
      }
    end
  end