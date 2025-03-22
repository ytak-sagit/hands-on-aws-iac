import json
import cfnresponse

# Lambda 関数ハンドラをカスタムリソース向けに修正
# cfnresponse によって、実行成否を、受け取ったイベントの中で指定された URL に通知する

def lambda_handler(event, context):
    try:
        print(json.dumps(event))
        cfnresponse.send(event, context, cfnresponse.SUCCESS, {}, "CustomResourcePhysicalID")
    except Exception as e:
        print(e)
        cfnresponse.send(event, context, cfnresponse.FAILED, {}, "CustomResourcePhysicalID")
