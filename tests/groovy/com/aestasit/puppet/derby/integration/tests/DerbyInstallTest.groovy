package dk.netcompany.puppet.derby.integration.tests

import static org.junit.Assert.*

import org.junit.After
import org.junit.Before
import org.junit.Test

import com.aestasit.puppet.integration.tests.BasePuppetIntegrationTest

/**
 * Derby installation test.
 *
 * @author Aestas/IT
 *
 */
class DerbyInstallTest extends BasePuppetIntegrationTest {

  @Before
  def void installDerby() {
    apply("include derby")
  }

  @Test
  def void ensureDerbyRunning() {
    command('service derby status > derbystatus.log')
    assertTrue fileText("/root/derbystatus.log").contains('Derby')
    assertTrue fileText("/root/derbystatus.log").contains('is running.')
  }

  @Test
  def void ensureCanConnect() {

    Thread.sleep(10000)
    uploadScript()
    command('/opt/derby/db-derby-10.9.1.0-bin/bin/ij testDataScript.sql > derbytest.log')

    // Check if the log of the insert operation contains the word ERROR.
    assertFalse ("The DB creation script returned at least one error",
        fileText("/root/derbytest.log").contains('ERROR'))

    // Check on data that was inserted into a table.
    assertTrue ("The DB creation script should contain a SELECT result",
        fileText("/root/derbytest.log").contains('Grand Ave.'))

  }

  def void uploadScript() {
    def url = Thread.currentThread().getContextClassLoader().getResource("derby/")
    if (url) {
      def file = new File(url.path)
      def s = file.path
      session {
        scp {
          from { localDir file }
          into { remoteDir '/root' }
        }
      }
    } else {
      fail("An error occurred while uploading the test scripts to the remote server!")
    }
  }
}
