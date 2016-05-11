package net.ripe.db.whois.spec.update

import net.ripe.db.whois.common.IntegrationTest
import net.ripe.db.whois.spec.BaseQueryUpdateSpec
import net.ripe.db.whois.spec.domain.AckResponse

@org.junit.experimental.categories.Category(IntegrationTest.class)
class LirMntByAttributeCountValidationSpec extends BaseQueryUpdateSpec {

    def "modify organisation, org-type:LIR, multiple user mnt-by"() {

        expect:
        queryObject("-r -T organisation ORG-LIR2-TEST", "organisation", "ORG-LIR2-TEST")

        when:
        def message = syncUpdate("""
                organisation: ORG-LIR2-TEST
                org-type:     LIR
                org-name:     Local Internet Registry
                address:      RIPE NCC
                e-mail:       dbtest@ripe.net
                admin-c:      SR1-TEST
                tech-c:       TP1-TEST
                ref-nfy:      dbtest-org@ripe.net
                mnt-ref:      owner3-mnt
                mnt-by:       ripe-ncc-hm-mnt
                mnt-by:       owner3-mnt
                mnt-by:       owner2-mnt
                source:       TEST

                password: hm
                """.stripIndent()
        )

        then:
        def ack = new AckResponse("", message)

        ack.summary.nrFound == 1
        ack.summary.assertSuccess(0, 0, 0, 0, 0)
        ack.summary.assertErrors(1, 0, 1, 0)
        ack.countErrorWarnInfo(1, 0, 0)

        ack.errors.any { it.operation == "Modify" && it.key == "[organisation] ORG-LIR2-TEST" }
        ack.errorMessagesFor("Modify", "[organisation] ORG-LIR2-TEST") ==
                ["Multiple user-'mnt-by:' are not allowed, found are: 'owner3-mnt, owner2-mnt'"]

        query_object_matches("-r -GBT organisation ORG-LIR2-TEST", "organisation", "ORG-LIR2-TEST", "LIR")
    }

    def "modify organisation, org-type:LIR, single user mnt-by"() {

        expect:
        queryObject("-r -T organisation ORG-LIR2-TEST", "organisation", "ORG-LIR2-TEST")

        when:
        def message = syncUpdate("""
                organisation: ORG-LIR2-TEST
                org-type:     LIR
                org-name:     Local Internet Registry
                address:      RIPE NCC
                e-mail:       dbtest@ripe.net
                admin-c:      SR1-TEST
                tech-c:       TP1-TEST
                ref-nfy:      dbtest-org@ripe.net
                mnt-ref:      owner3-mnt
                mnt-by:       ripe-ncc-hm-mnt
                mnt-by:       owner3-mnt
                source:       TEST

                password: hm
                """.stripIndent()
        )

        then:
        def ack = new AckResponse("", message)

        ack.summary.nrFound == 1
        ack.summary.assertSuccess(1, 0, 1, 0, 0)
        ack.summary.assertErrors(0, 0, 0, 0)
        ack.countErrorWarnInfo(0, 0, 0)

        query_object_matches("-r -GBT organisation ORG-LIR2-TEST", "organisation", "ORG-LIR2-TEST", "LIR")
    }
}