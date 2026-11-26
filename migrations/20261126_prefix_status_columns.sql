BEGIN;

ALTER TABLE "case_evidences" RENAME COLUMN "analysis_status" TO "case_evidences_analysis_status";
ALTER TABLE "case_interactions" RENAME COLUMN "status" TO "case_interactions_status";
ALTER TABLE "case_status_histories" RENAME COLUMN "status" TO "case_timeline_status";
ALTER TABLE "cases" RENAME COLUMN "status" TO "cases_status";
ALTER TABLE "dispute_posts" RENAME COLUMN "resolution_status" TO "dispute_posts_resolution_status";
ALTER TABLE "email_drafts" RENAME COLUMN "status" TO "email_drafts_status";
ALTER TABLE "email_send_attempts" RENAME COLUMN "status" TO "email_send_attempts_status";
ALTER TABLE "gmail_connections" RENAME COLUMN "status" TO "gmail_connections_status";
ALTER TABLE "orchestrator_runs" RENAME COLUMN "status" TO "orchestrator_runs_status";
ALTER TABLE "question_posts" RENAME COLUMN "question_status" TO "question_posts_question_status";
ALTER TABLE "users" RENAME COLUMN "status" TO "users_status";

COMMIT;
