BEGIN;

ALTER TABLE "email_send_attempts" DROP COLUMN IF EXISTS "draft_revision";
ALTER TABLE "email_drafts" DROP COLUMN IF EXISTS "revision";

COMMENT ON TABLE "email_drafts" IS 'purpose:
REFUND_REQUEST
PAYMENT_CORRECTION
ADDITIONAL_INFORMATION
FOLLOW_UP
OTHER

email_drafts_status:
DRAFT - 이메일 작성 중이거나 수정으로 재승인이 필요한 상태
FINALIZED - 사용자가 현재 이메일 초안을 확인하고 발송 승인한 상태
SENT - Gmail 발송 성공과 메시지 ID 저장이 완료된 상태

승인된 초안의 수신자, 제목, 본문 또는 첨부를 수정하면 DRAFT로 전환한다.
발송이 진행 중이거나 결과 확인 중인 초안의 수정은 차단한다.
SENT 초안은 수정할 수 없으며 새 발송에는 새 초안을 만든다.

사용자와 AI의 대화에 따라
subject, body를 갱신한다.
';

COMMENT ON TABLE "email_send_attempts" IS '상태는 SENDING, UNKNOWN, FAILED, SENT를 사용한다.
서버는 초안과 첨부 변경을 초안 행 잠금으로 직렬화한다.
회원·사건 소유권, Gmail 연결, FINALIZED 상태를 검증하고 초안당 한 행으로 발송을 선점한다.
선점 트랜잭션 커밋 후 고정된 Message-ID 헤더로 Gmail을 호출한다.
Gmail 성공 시 스레드·발송 메시지 및 Gmail 메시지 ID를 저장하고 초안과 발송 행을 같은 트랜잭션에서 SENT로 변경한다.
타임아웃이나 중단으로 결과가 불확실하면 재전송을 막고 Gmail 발송함에서 Message-ID로 확인한다.
검색 결과가 없다는 이유만으로 재전송하지 않는다. 미발송이 확정된 FAILED만 기존 발송 행으로 다시 선점한다.
기존 FINALIZED에 명시적 승인 근거가 없는 환경에서는 발송 기능 적용 전에 DRAFT로 되돌린다.';

COMMIT;
