DELETE
FROM `{project_id}.{dataset_name}.{table_name}` main
WHERE EXISTS(
    SELECT
        '1'
    FROM
        `{project_id}.{latest_dataset_name}.{table_name}` sub
    WHERE
        main.rnki_jkn = sub.rnki_jkn
    AND
        main.skbt_id = sub.skbt_id
    );

INSERT INTO `{project_id}.{dataset_name}.{table_name}`
(
    rnki_jkn,   -- 連携時間
    skbt_id,    -- 識別ID
    kiin_flag,  -- 会員フラグ
    test_value  -- 値
)
SELECT
    rnki_jkn,
    skbt_id,
    kiin_flag,
    test_value
FROM
    `{project_id}.{latest_dataset_name}.{table_name}` latest;

-- 場合によってはこっちも使うかも
MERGE INTO `{project_id}.{dataset_name}.{table_name}` target_table AS target
    USING `{project_id}.{latest_dataset_name}.{table_name}` source_table AS source
    ON target.rnki_jkn = source.rnki_jkn
    AND target.skbt_id = source.skbt_id
    WHEN MATCHED THEN
UPDATE SET
    target.kiin_flag = source.kiin_flag,
    target.test_value = source.test_value
    WHEN NOT MATCHED THEN
INSERT (rnki_jkn, skbt_id, kiin_flag, test_value)
VALUES (source.rnki_jkn, source.skbt_id, source.kiin_flag, source.test_value);
