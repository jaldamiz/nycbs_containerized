

-- Extract a sample row and transpose it for easier visualization
with sample_data as (
    select *
    from "dev"."raw_raw"."tripdata_ext"
    limit 1
)

select 'col-6fdc68ca-05d2-4192-bab6-f5f3004afc91' as column_id, cast("col-6fdc68ca-05d2-4192-bab6-f5f3004afc91" as varchar) as value from sample_data
union all select 'col-7037afb6-dcc6-4f1f-928e-a9e42a8272ad', cast("col-7037afb6-dcc6-4f1f-928e-a9e42a8272ad" as varchar) from sample_data
union all select 'col-c9a74aca-e814-4ee4-821e-586618418d54', cast("col-c9a74aca-e814-4ee4-821e-586618418d54" as varchar) from sample_data
union all select 'col-af2e2fa9-2758-4a10-8998-233a12e42bd2', cast("col-af2e2fa9-2758-4a10-8998-233a12e42bd2" as varchar) from sample_data
union all select 'col-18983d2a-741b-4a7f-bee1-9ba67e9b203f', cast("col-18983d2a-741b-4a7f-bee1-9ba67e9b203f" as varchar) from sample_data
union all select 'col-53f70002-3545-4b79-a45d-6be2702b4da5', cast("col-53f70002-3545-4b79-a45d-6be2702b4da5" as varchar) from sample_data
union all select 'col-3ccb12ef-5e30-4dd7-b7ff-de9f0ffb1dc5', cast("col-3ccb12ef-5e30-4dd7-b7ff-de9f0ffb1dc5" as varchar) from sample_data
union all select 'col-969c544e-964d-4c3c-95de-a0ae59081905', cast("col-969c544e-964d-4c3c-95de-a0ae59081905" as varchar) from sample_data
union all select 'col-0e4da5e8-fa3a-4e0d-b4c0-f383882e5628', cast("col-0e4da5e8-fa3a-4e0d-b4c0-f383882e5628" as varchar) from sample_data
union all select 'col-5abb0215-e0dc-4d85-be04-c3578803127c', cast("col-5abb0215-e0dc-4d85-be04-c3578803127c" as varchar) from sample_data
union all select 'col-f4a9d89d-2326-4bc6-9b5f-dd134b52b4a1', cast("col-f4a9d89d-2326-4bc6-9b5f-dd134b52b4a1" as varchar) from sample_data
union all select 'col-eec30ea1-5af2-4ab1-a29b-8c1cd872af81', cast("col-eec30ea1-5af2-4ab1-a29b-8c1cd872af81" as varchar) from sample_data
union all select 'col-2bedf5fb-1e29-4f00-83ac-27a2a55b2033', cast("col-2bedf5fb-1e29-4f00-83ac-27a2a55b2033" as varchar) from sample_data
union all select 'col-390407bc-d964-4112-a39a-99be8c89070a', cast("col-390407bc-d964-4112-a39a-99be8c89070a" as varchar) from sample_data
union all select 'col-00a66823-a7c2-4581-b24f-b136f5940a2d', cast("col-00a66823-a7c2-4581-b24f-b136f5940a2d" as varchar) from sample_data
union all select 'col-e9040462-816b-4f4f-99e1-33185f2bfac1', cast("col-e9040462-816b-4f4f-99e1-33185f2bfac1" as varchar) from sample_data
union all select 'col-3b584773-0c1c-4160-ba3d-dc010abcd5b9', cast("col-3b584773-0c1c-4160-ba3d-dc010abcd5b9" as varchar) from sample_data
union all select 'col-78497edf-4b93-46b5-86f2-6c1824f8a8b3', cast("col-78497edf-4b93-46b5-86f2-6c1824f8a8b3" as varchar) from sample_data
union all select 'col-1f6239f4-6e36-41ae-bdcd-2ba4a40f703d', cast("col-1f6239f4-6e36-41ae-bdcd-2ba4a40f703d" as varchar) from sample_data
union all select 'col-4cd31af1-f22d-4fb2-83dc-4132a0621f26', cast("col-4cd31af1-f22d-4fb2-83dc-4132a0621f26" as varchar) from sample_data
union all select 'col-81d0d7f8-9682-4836-ac3b-d1fc099d6e51', cast("col-81d0d7f8-9682-4836-ac3b-d1fc099d6e51" as varchar) from sample_data
union all select 'col-b9bb1351-dcb9-46c3-958c-e6c8aefc083f', cast("col-b9bb1351-dcb9-46c3-958c-e6c8aefc083f" as varchar) from sample_data