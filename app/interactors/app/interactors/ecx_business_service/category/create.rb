class EcxBusinessService::Category::Create
    include Interactor

    def call
        context[:category] = EcxBusinessService::Category.find_or_create_by(title: context[:category_params][:title], parent_id: context[:category_params][:parent_id])
    end
end